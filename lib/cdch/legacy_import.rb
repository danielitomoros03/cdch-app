require "bigdecimal"

module Cdch
  # Carga la base unificada del ETL (CDCH/etl → cdch_unificado.sqlite) en las tablas
  # de investigadores. Se puede repetir: personas y proyectos se actualizan por su
  # clave natural (cédula; tipo + código), así sus ids y enlaces se mantienen; el
  # resto se reemplaza completo. Todo corre en una transacción.
  #
  # Los arbitrajes no se cargan todavía: esperan su regla de confidencialidad.
  class LegacyImport
    BATCH = 1_000
    VALID_YEARS = 1950..2030
    FLAG_RATIO = 10

    PAYROLL_STATUS = {
      "Activo" => "active",
      "Directiva docente" => "management",
      "Jubilado o pensionado" => "retired"
    }.freeze

    CONTACT_KIND = { "email" => "email", "telefono" => "phone", "direccion" => "address" }.freeze

    # Tablas que se vacían y se vuelven a llenar, de hijas a madres.
    REPLACED = [
      StageCoInvestigator, StagePublication, StageExtension, ProjectStage,
      InstitutionalAid, Scholarship, PersonContact, UcvAppointment, PpiLevel
    ].freeze

    attr_reader :report

    def initialize(path, io: $stdout)
      @path = path.to_s
      @io = io
      @report = Hash.new(0)
    end

    def call
      require "sqlite3"
      raise ArgumentError, "No existe la base unificada: #{@path}" unless File.exist?(@path)

      @db = SQLite3::Database.new(@path, readonly: true, results_as_hash: true)
      @now = Time.current

      ActiveRecord::Base.transaction do
        REPLACED.each { |model| model.delete_all }
        import_catalogs
        import_people
        import_contacts
        import_appointments
        import_ppi
        import_projects
        import_stages
        import_co_investigators
        import_publications
        import_extensions
        import_aids
        import_scholarships
        remove_stale_projects
      end

      print_report
      report
    ensure
      @db&.close
    end

    private

    # --- Catálogos -----------------------------------------------------------

    def import_catalogs
      upsert Faculty, rows("SELECT codigo, nombre FROM cat_facultad WHERE codigo <> ''").map { |r|
        { code: r["codigo"], name: r["nombre"].presence || r["codigo"] }
      }, unique_by: :code

      upsert ResearchArea, rows("SELECT id, nombre FROM cat_area").map { |r|
        { legacy_id: r["id"], name: r["nombre"] }
      }, unique_by: :legacy_id

      upsert FundingSource, rows("SELECT id, nombre FROM cat_fondo").map { |r|
        { code: r["id"], name: r["nombre"] }
      }, unique_by: :code

      upsert LegacyStatus, rows("SELECT id, nombre, aplica_a FROM cat_estado").map { |r|
        { legacy_id: r["id"], name: r["nombre"], applies_to: r["aplica_a"] }
      }, unique_by: :legacy_id

      upsert ProjectType, rows(<<~SQL).map { |r| { code: r["tipo"], name: r["nombre"], program: r["programa"], current: r["vigente"] == 1 } }, unique_by: :code
        SELECT s.tipo, s.nombre, p.nombre AS programa, s.vigente
        FROM cat_subprograma s LEFT JOIN cat_programa p ON p.id = s.programa_id
      SQL

      upsert UcvUnit, rows("SELECT codigo, codigo_corto, nombre, estado FROM cat_unidad_ucv").map { |r|
        { code: r["codigo"], short_code: r["codigo_corto"], name: r["nombre"], status: r["estado"] }
      }, unique_by: :code

      @area_ids = ResearchArea.pluck(:legacy_id, :id).to_h
      @status_ids = LegacyStatus.pluck(:legacy_id, :id).to_h
      @funding_codes = FundingSource.pluck(:code).to_set
    end

    # --- Personas ------------------------------------------------------------

    def import_people
      categories = rows("SELECT id, nombre FROM cat_categoria").to_h { |r| [ r["id"], r["nombre"] ] }
      dedications = rows("SELECT id, nombre FROM cat_dedicacion").to_h { |r| [ r["id"], r["nombre"] ] }

      people = rows("SELECT * FROM persona").map do |r|
        {
          id_number: r["cedula"],
          nationality: r["nacionalidad"].presence,
          first_names: r["nombres"],
          last_names: r["apellidos"],
          full_name: r["nombre_completo"].presence || r["nombre_nomina"].presence || r["cedula"],
          payroll_name: r["nombre_nomina"],
          in_payroll: r["en_nomina_2026"] == 1,
          payroll_status: PAYROLL_STATUS[r["situacion_nomina"]],
          legacy_condition: r["condicion_legado"],
          legacy_faculty_code: r["facultad_legado"],
          legacy_category: categories[r["categoria_legado_id"]],
          legacy_dedication: dedications[r["dedicacion_legado_id"]],
          legacy_position: r["cargo_legado"],
          project_lead: r["es_responsable_proyecto"] == 1,
          co_investigator: r["es_coinvestigador"] == 1,
          reviewer: r["es_arbitro"] == 1,
          aid_applicant: r["es_solicitante_ayuda"] == 1,
          scholar: r["es_becario"] == 1,
          sources: r["fuentes"]
        }
      end
      # upsert_all no pasa por `normalizes`: se aplica a mano para guardar los nombres en mayúsculas.
      people.each { |person| Person::NAME_FIELDS.each { |field| person[field] = Person.normalize_value_for(field, person[field]) } }
      upsert Person, people, unique_by: :id_number

      # id de persona en la base unificada → id en Postgres
      ids_by_number = Person.pluck(:id_number, :id).to_h
      @person_ids = rows("SELECT id, cedula FROM persona").to_h { |r| [ r["id"], ids_by_number.fetch(r["cedula"]) ] }
    end

    def import_contacts
      contacts = rows("SELECT persona_id, tipo, valor, fuente FROM persona_contacto").filter_map do |r|
        kind = CONTACT_KIND[r["tipo"]]
        next count(:contactos_omitidos) unless kind && r["valor"].present?

        { person_id: person(r["persona_id"]), kind: kind, value: r["valor"].strip, source: r["fuente"] }
      end
      insert PersonContact, contacts.uniq { |c| c.values_at(:person_id, :kind, :value) }
    end

    def import_appointments
      insert UcvAppointment, rows("SELECT * FROM cargo_ucv").map { |r|
        {
          person_id: person(r["persona_id"]),
          payroll_type_code: r["tipo_nomina_cod"], payroll_type: r["tipo_nomina"],
          dependency_code: r["dependencia_cod"], dependency: r["dependencia"],
          ucv_unit_code: r["unidad_ejecutora"].presence, ucv_unit_name: r["unidad_ejecutora_nombre"],
          hired_on: date(r["fecha_ingreso"]), retired_on: date(r["fecha_jubilacion"]),
          years_at_ucv: r["anios_ucv"],
          dedication_code: r["dedicacion_cod"], dedication: r["dedicacion"],
          category_code: r["categoria_cod"], category: r["categoria"],
          source: r["fuente"]
        }
      }
    end

    def import_ppi
      insert PpiLevel, rows("SELECT * FROM persona_ppi").map { |r|
        { person_id: person(r["persona_id"]), level: r["nivel"], committee: r["comision_evaluadora"], source: r["fuente"] }
      }
    end

    # --- Proyectos (DADI) ----------------------------------------------------

    def import_projects
      @source_project_keys = Set.new
      projects = rows("SELECT * FROM proyecto").map do |r|
        @source_project_keys << [ r["tipo"], r["codigo"] ]
        {
          department_id: dadi.id,
          project_type_code: r["tipo"], code: r["codigo"], legacy_code: r["codigo_anterior"],
          title: r["titulo"],
          lead_person_id: person(r["responsable_persona_id"]),
          faculty_code: r["facultad_cod"].presence,
          research_area_id: @area_ids[r["area_id"]],
          specialty: r["especialidad"],
          total_stages: r["etapas_totales"],
          first_requested_on: date(r["primera_solicitud"]),
          last_requested_on: date(r["ultima_solicitud"])
        }
      end
      upsert ResearchProject, projects, unique_by: %i[project_type_code code]

      ids_by_key = ResearchProject.pluck(:project_type_code, :code, :id).to_h { |type, code, id| [ [ type, code ], id ] }
      @project_ids = rows("SELECT id, tipo, codigo FROM proyecto").to_h { |r| [ r["id"], ids_by_key.fetch([ r["tipo"], r["codigo"] ]) ] }
    end

    def import_stages
      stages = rows("SELECT * FROM proyecto_etapa").map do |r|
        {
          research_project_id: @project_ids.fetch(r["proyecto_id"]),
          legacy_id: r["id"],
          number: r["etapa"], total_stages: r["etapas_totales"], serial: r["correlativo"],
          lead_person_id: person(r["responsable_persona_id"]),
          faculty_code: r["facultad_cod"].presence,
          legacy_status_id: @status_ids[r["estado_id"]],
          research_area_id: @area_ids[r["area_id"]], area_text: r["area_texto"],
          specialty: r["especialidad"], title: r["titulo"],
          cofinanced: bool(r["cofinanciado"]),
          requested_on: date(r["fecha_solicitud"]),
          amount_requested: money(r["monto_solicitado"]),
          approved_on: date(r["fecha_aprobacion"]),
          contract: r["contrato"], signed_on: date(r["fecha_firma"]),
          amount_approved: money(r["monto_aprobado"]),
          stage_variation: money(r["variacion_etapa"]),
          amount_equipment: money(r["monto_equipos"]), amount_supplies: money(r["monto_materiales"]),
          amount_travel: money(r["monto_viajes"]), amount_services: money(r["monto_servicios"]),
          amount_personnel: money(r["monto_personal"]), amount_other: money(r["monto_otros"]),
          currency: r["moneda"].presence,
          amount_flagged: flagged?(r, :montos_marcados_etapas),
          partial_report_approved_on: date(r["fecha_aprob_informe_parcial"]),
          partial_report_ok: bool(r["informe_parcial_conforme"]),
          final_report_approved_on: date(r["fecha_aprob_informe_final"]),
          final_report_ok: bool(r["informe_final_conforme"]),
          notes: r["observaciones"].presence, merge_note: r["fusion"].presence,
          extension_on: date(r["fecha_prorroga"]), extension_code: r["prorroga_id"],
          duration_months: r["duracion"],
          work_approved_on: date(r["fecha_aprob_trabajo"]),
          work_title: r["titulo_trabajo"].presence, work_journal: r["revista_trabajo"].presence,
          funding_source_code: funding(r["fondo_id"]),
          code: r["codigo"], legacy_code: r["codigo_anterior"], source: r["fuente"]
        }
      end
      insert ProjectStage, stages
      @stage_ids = ProjectStage.pluck(:legacy_id, :id).to_h
    end

    def import_co_investigators
      insert StageCoInvestigator, rows("SELECT * FROM coinvestigador").map { |r|
        count(:coinvestigadores_sin_etapa) if r["proyecto_etapa_id"].nil?
        { project_stage_id: stage(r["proyecto_etapa_id"]), person_id: person(r["persona_id"]), project_code: r["codigo"], stage_number: r["etapa"] }
      }
    end

    def import_publications
      insert StagePublication, rows("SELECT * FROM publicacion_proyecto").map { |r|
        {
          project_stage_id: stage(r["proyecto_etapa_id"]), legacy_code: r["codigo_anterior"], stage_number: r["etapa"],
          title: r["titulo"], venue: r["donde_se_publico"], evaluated_on: date(r["fecha_evaluacion"])
        }
      }
    end

    def import_extensions
      insert StageExtension, rows("SELECT * FROM prorroga_proyecto").map { |r|
        { project_stage_id: @stage_ids.fetch(r["proyecto_etapa_id"]), stage_number: r["etapa"], granted_on: date(r["fecha"]) }
      }
    end

    # --- Ayudas (DADI) y becas (DADA) ----------------------------------------

    def import_aids
      insert InstitutionalAid, rows("SELECT * FROM ayuda_institucional").map { |r|
        {
          department_id: dadi.id, legacy_id: r["id"],
          aid_type_code: r["tipo"], code: r["codigo"], legacy_code: r["codigo_anterior"], serial: r["correlativo"],
          applicant_person_id: person(r["solicitante_persona_id"]),
          faculty_code: r["facultad_cod"].presence, dependency: r["dependencia"],
          description: r["descripcion"], legacy_status_id: @status_ids[r["estado_id"]],
          requested_on: date(r["fecha_solicitud"]), amount_requested: money(r["monto_solicitado"]),
          approved_on: date(r["fecha_aprobacion"]), amount_approved: money(r["monto_aprobado"]),
          amount_equipment: money(r["monto_equipos"]), amount_supplies: money(r["monto_materiales"]),
          amount_travel: money(r["monto_viajes"]), amount_services: money(r["monto_servicios"]),
          amount_other: money(r["monto_otros"]),
          currency: r["moneda"].presence,
          amount_flagged: flagged?(r, :montos_marcados_ayudas),
          report_approved_on: date(r["fecha_aprob_informe"]), report_ok: bool(r["informe_conforme"]),
          extension_on: date(r["fecha_prorroga"]), extension_code: r["prorroga_id"], duration_months: r["duracion"],
          notes: r["observaciones"].presence, merge_note: r["fusion"].presence,
          funding_source_code: funding(r["fondo_id"])
        }
      }
    end

    def import_scholarships
      insert Scholarship, rows("SELECT * FROM beca").map { |r|
        {
          department_id: dada.id, legacy_id: r["id"], person_id: person(r["persona_id"]),
          program: r["programa"], scholarship_type: r["tipo_beca"], level: r["nivel"], specialty: r["especialidad"],
          institution: r["institucion"], country: r["pais"], faculty: r["facultad"], dependency: r["dependencia"],
          rank: r["escalafon"], dedication: r["dedicacion"],
          approved_on: date(r["fecha_aprobacion"]), starts_on: date(r["fecha_inicio"]), ends_on: date(r["fecha_fin"]),
          last_extension_on: date(r["fecha_ultima_prorroga"]), degree_filed_on: date(r["fecha_consignacion_titulo"]),
          status: r["estado"].presence, file_number: r["expediente"],
          notes: r["observaciones"].presence, follow_up: r["seguimiento"].presence, source: r["fuente"]
        }
      }
    end

    # Proyectos que ya no vienen en la base unificada (por ejemplo, tras corregir un código).
    def remove_stale_projects
      stale = ResearchProject.pluck(:id, :project_type_code, :code).reject { |_, type, code| @source_project_keys.include?([ type, code ]) }
      ResearchProject.where(id: stale.map(&:first)).delete_all if stale.any?
      report[:proyectos_retirados] = stale.size
    end

    # --- Utilidades ----------------------------------------------------------

    # El FoxPro guardaba la Ñ como el byte 0xA5 de cp850; leído como cp1252 sale "¥".
    def rows(sql)
      @db.execute(sql).each do |row|
        row.transform_values! { |value| value.is_a?(String) ? value.tr("¥", "Ñ") : value }
      end
    end

    def upsert(model, records, unique_by:)
      records.each_slice(BATCH) { |batch| model.upsert_all(stamp(batch, created: true), unique_by: unique_by, record_timestamps: false) }
      report[model.table_name] = model.count
    end

    def insert(model, records)
      records.each_slice(BATCH) { |batch| model.insert_all!(stamp(batch, created: true), record_timestamps: false) }
      report[model.table_name] = model.count
    end

    def stamp(batch, created:)
      batch.map { |record| record.merge(updated_at: @now).tap { |r| r[:created_at] = @now if created } }
    end

    def person(source_id)
      source_id && @person_ids.fetch(source_id)
    end

    def stage(source_id)
      source_id && @stage_ids.fetch(source_id)
    end

    def funding(code)
      return if code.blank?
      return code if @funding_codes.include?(code)

      count(:fondos_desconocidos)
      nil
    end

    def date(value)
      return if value.blank?

      parsed = Date.iso8601(value.to_s[0, 10])
      return parsed if VALID_YEARS.cover?(parsed.year)

      count(:fechas_fuera_de_rango)
      nil
    rescue Date::Error
      count(:fechas_invalidas)
      nil
    end

    def money(value)
      value.nil? ? nil : BigDecimal(value.to_s).round(2)
    end

    def bool(value)
      value.nil? ? nil : value == 1
    end

    # Aprobado más de 10 veces lo solicitado: casi siempre un error de captura
    # (el caso conocido perdió la coma decimal).
    def flagged?(row, counter)
      requested = row["monto_solicitado"].to_f
      approved = row["monto_aprobado"].to_f
      (requested.positive? && approved > requested * FLAG_RATIO).tap { |flag| count(counter) if flag }
    end

    def count(key)
      report[key] += 1
      nil
    end

    def dadi
      @dadi ||= Department.find_by!(code: "2700060000")
    end

    def dada
      @dada ||= Department.find_by!(code: "2700050000")
    end

    def print_report
      @io.puts "Carga terminada:"
      report.sort_by { |key, _| key.to_s }.each { |key, value| @io.puts format("  %-32s %8d", key, value) }
    end
  end
end
