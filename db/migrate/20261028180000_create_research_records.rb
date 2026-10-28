# Investigadores y su historia en el CDCH, cargados desde la nómina docente 2026 y
# el sistema FoxPro del Dpto. de Proyectos (1985–2019). Solo lectura por ahora: se
# llenan con `rails cdch:import`. Los arbitrajes quedan fuera hasta tener su regla
# de confidencialidad.
class CreateResearchRecords < ActiveRecord::Migration[7.2]
  CURRENCIES = "currency IS NULL OR currency IN ('VEB', 'VEF', 'VES', 'VED')".freeze

  def change
    # Catálogos del sistema heredado
    create_table :faculties do |t|
      t.string :code, null: false, index: { unique: true }
      t.string :name, null: false
      t.timestamps
    end

    create_table :research_areas do |t|
      t.integer :legacy_id, null: false, index: { unique: true }
      t.string :name, null: false
      t.timestamps
    end

    create_table :funding_sources do |t|
      t.string :code, null: false, index: { unique: true }
      t.string :name
      t.timestamps
    end

    create_table :legacy_statuses do |t|
      t.integer :legacy_id, null: false, index: { unique: true }
      t.string :name, null: false
      t.string :applies_to
      t.timestamps
    end

    create_table :project_types do |t|
      t.string :code, null: false, index: { unique: true }
      t.string :name
      t.string :program
      t.boolean :current, null: false, default: false
      t.timestamps
    end

    create_table :ucv_units do |t|
      t.string :code, null: false, index: { unique: true }
      t.string :short_code
      t.string :name
      t.string :status
      t.timestamps
    end

    # Personas
    create_table :people do |t|
      t.string :id_number, null: false, index: { unique: true }
      t.string :nationality
      t.string :first_names
      t.string :last_names
      t.string :full_name, null: false
      t.string :payroll_name
      t.boolean :in_payroll, null: false, default: false
      t.string :payroll_status
      t.string :legacy_condition
      t.string :legacy_faculty_code
      t.string :legacy_category
      t.string :legacy_dedication
      t.string :legacy_position
      t.boolean :project_lead, null: false, default: false
      t.boolean :co_investigator, null: false, default: false
      t.boolean :reviewer, null: false, default: false
      t.boolean :aid_applicant, null: false, default: false
      t.boolean :scholar, null: false, default: false
      t.string :sources
      t.timestamps

      t.index :full_name
      t.index :payroll_status
      t.check_constraint "payroll_status IS NULL OR payroll_status IN ('active', 'management', 'retired')", name: "people_payroll_status"
    end

    create_table :person_contacts do |t|
      t.references :person, null: false, foreign_key: { on_delete: :cascade }
      t.string :kind, null: false
      t.string :value, null: false
      t.string :source
      t.timestamps

      t.index [ :person_id, :kind, :value ], unique: true
      t.check_constraint "kind IN ('email', 'phone', 'address')", name: "person_contacts_kind"
    end

    create_table :ucv_appointments do |t|
      t.references :person, null: false, foreign_key: { on_delete: :cascade }
      t.string :payroll_type_code
      t.string :payroll_type
      t.string :dependency_code
      t.string :dependency
      t.string :ucv_unit_code, index: true
      t.string :ucv_unit_name
      t.date :hired_on
      t.date :retired_on
      t.integer :years_at_ucv
      t.string :dedication_code
      t.string :dedication
      t.string :category_code
      t.string :category
      t.string :source
      t.timestamps
    end

    create_table :ppi_levels do |t|
      t.references :person, null: false, foreign_key: { on_delete: :cascade }
      t.string :level
      t.string :committee
      t.string :source
      t.timestamps
    end

    # Proyectos de investigación (DADI)
    create_table :research_projects do |t|
      t.references :department, null: false, foreign_key: true
      t.string :project_type_code, null: false, index: true
      t.string :code, null: false
      t.string :legacy_code
      t.text :title
      t.references :lead_person, foreign_key: { to_table: :people }
      t.string :faculty_code, index: true
      t.references :research_area, foreign_key: true
      t.string :specialty
      t.integer :total_stages
      t.date :first_requested_on
      t.date :last_requested_on
      t.timestamps

      t.index [ :project_type_code, :code ], unique: true
      t.index :legacy_code
    end

    create_table :project_stages do |t|
      t.references :research_project, null: false, foreign_key: true
      t.integer :legacy_id, null: false, index: { unique: true }
      t.integer :number
      t.integer :total_stages
      t.string :serial
      t.references :lead_person, foreign_key: { to_table: :people }
      t.string :faculty_code
      t.references :legacy_status, foreign_key: true
      t.references :research_area, foreign_key: true
      t.string :area_text
      t.string :specialty
      t.text :title
      t.boolean :cofinanced
      t.date :requested_on, index: true
      t.decimal :amount_requested, precision: 20, scale: 2
      t.date :approved_on
      t.string :contract
      t.date :signed_on
      t.decimal :amount_approved, precision: 20, scale: 2
      t.decimal :stage_variation, precision: 20, scale: 2
      t.decimal :amount_equipment, precision: 20, scale: 2
      t.decimal :amount_supplies, precision: 20, scale: 2
      t.decimal :amount_travel, precision: 20, scale: 2
      t.decimal :amount_services, precision: 20, scale: 2
      t.decimal :amount_personnel, precision: 20, scale: 2
      t.decimal :amount_other, precision: 20, scale: 2
      t.string :currency
      t.boolean :amount_flagged, null: false, default: false
      t.date :partial_report_approved_on
      t.boolean :partial_report_ok
      t.date :final_report_approved_on
      t.boolean :final_report_ok
      t.text :notes
      t.string :merge_note
      t.date :extension_on
      t.integer :extension_code
      t.integer :duration_months
      t.date :work_approved_on
      t.text :work_title
      t.text :work_journal
      t.string :funding_source_code
      t.string :code
      t.string :legacy_code
      t.string :source
      t.timestamps

      t.check_constraint CURRENCIES, name: "project_stages_currency"
    end

    create_table :stage_co_investigators do |t|
      t.references :project_stage, foreign_key: true
      t.references :person, null: false, foreign_key: true
      t.string :project_code
      t.integer :stage_number
      t.timestamps
    end

    create_table :stage_publications do |t|
      t.references :project_stage, foreign_key: true
      t.string :legacy_code
      t.integer :stage_number
      t.text :title
      t.text :venue
      t.date :evaluated_on
      t.timestamps
    end

    create_table :stage_extensions do |t|
      t.references :project_stage, null: false, foreign_key: true
      t.integer :stage_number
      t.date :granted_on
      t.timestamps
    end

    # Ayudas institucionales (DADI)
    create_table :institutional_aids do |t|
      t.references :department, null: false, foreign_key: true
      t.integer :legacy_id, null: false, index: { unique: true }
      t.string :aid_type_code, index: true
      t.string :code
      t.string :legacy_code
      t.string :serial
      t.references :applicant_person, foreign_key: { to_table: :people }
      t.string :faculty_code
      t.string :dependency
      t.text :description
      t.references :legacy_status, foreign_key: true
      t.date :requested_on, index: true
      t.decimal :amount_requested, precision: 20, scale: 2
      t.date :approved_on
      t.decimal :amount_approved, precision: 20, scale: 2
      t.decimal :amount_equipment, precision: 20, scale: 2
      t.decimal :amount_supplies, precision: 20, scale: 2
      t.decimal :amount_travel, precision: 20, scale: 2
      t.decimal :amount_services, precision: 20, scale: 2
      t.decimal :amount_other, precision: 20, scale: 2
      t.string :currency
      t.boolean :amount_flagged, null: false, default: false
      t.date :report_approved_on
      t.boolean :report_ok
      t.date :extension_on
      t.integer :extension_code
      t.integer :duration_months
      t.text :notes
      t.string :merge_note
      t.string :funding_source_code
      t.timestamps

      t.check_constraint CURRENCIES, name: "institutional_aids_currency"
    end

    # Becas (DADA)
    create_table :scholarships do |t|
      t.references :department, null: false, foreign_key: true
      t.integer :legacy_id, null: false, index: { unique: true }
      t.references :person, null: false, foreign_key: true
      t.string :program
      t.string :scholarship_type
      t.string :level
      t.string :specialty
      t.string :institution
      t.string :country
      t.string :faculty
      t.string :dependency
      t.string :rank
      t.string :dedication
      t.date :approved_on
      t.date :starts_on
      t.date :ends_on
      t.date :last_extension_on
      t.date :degree_filed_on
      t.string :status
      t.string :file_number
      t.text :notes
      t.text :follow_up
      t.string :source
      t.timestamps
    end
  end
end
