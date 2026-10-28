# Applies the CDCH "Clasificador estructural" (unidades ejecutoras) to departments.
#
# Existing departments keep their acronym and display name, because public pages,
# logos ("#{acronym}.png") and DTIC permissions depend on them. Each unit lists every
# acronym it is known by: production uses "Admin", "DAC" and "Saber UCV" (the DCTI),
# while development seeds use longer ones. Subdirección holds the classifier code
# 2701000000 (formerly Secretaría Ejecutiva). A unit that does not exist yet, like
# DCTI on a fresh seed, is created hidden from the public site. Departments outside
# the classifier stay without a code.
class ApplyStructuralClassifierToDepartments < ActiveRecord::Migration[7.2]
  class MigrationDepartment < ActiveRecord::Base
    self.table_name = "departments"
  end

  class MigrationUser < ActiveRecord::Base
    self.table_name = "users"
  end

  CLASSIFIER = [
    { acronyms: %w[Dir],                                         code: "2700000000", parent: nil,              official_name: "Dirección del Consejo de Desarrollo Científico y Humanístico (CDCH)" },
    { acronyms: %w[Subdir],                                      code: "2701000000", parent: "2700000000",     official_name: "Subdirección" },
    { acronyms: ["Admin", "Administración"],                     code: "2700010000", parent: "2700000000",     official_name: "Departamento de Apoyo Administrativo" },
    { acronyms: %w[Compras],                                     code: "2700010100", parent: "2700010000",     official_name: "Sección de Compras" },
    { acronyms: ["DAC", "Archivo y Correspondencia"],            code: "2700020000", parent: "2700000000",     official_name: "Departamento de Archivo y Correspondencia" },
    { acronyms: %w[DTIC],                                        code: "2700040000", parent: "2700000000",     official_name: "Departamento de Tecnología de Información y Comunicación (DTIC)" },
    { acronyms: %w[DADA],                                        code: "2700050000", parent: "2700000000",     official_name: "Departamento de Apoyo al Desarrollo Académico (DADA)" },
    { acronyms: %w[DADI],                                        code: "2700060000", parent: "2700000000",     official_name: "Departamento de Apoyo al Desarrollo de la Investigación (DADI)" },
    { acronyms: %w[Publicaciones],                               code: "2700070000", parent: "2700000000",     official_name: "Departamento de Relaciones y Publicaciones" },
    { acronyms: ["DCTI", "Saber UCV"],                           code: "2700080000", parent: "2700000000",     official_name: "Departamento de Ciencia, Tecnología e Innovación (DCTI)", create_name: "Departamento de Ciencia, Tecnología e Innovación" }
  ].freeze

  def up
    MigrationDepartment.reset_column_information

    CLASSIFIER.each do |unit|
      department = find_by_acronyms(unit[:acronyms])

      if department.nil? && unit[:create_name]
        department = MigrationDepartment.create!(
          acronym: unit[:acronyms].first,
          name: unit[:create_name],
          organize: MigrationDepartment.maximum(:organize).to_i + 1,
          public_visible: false
        )
        say "Creado: #{department.acronym} (oculto en el sitio público)"
      end

      if department.nil?
        say "No encontrado, se omite: #{unit[:acronyms].join(" / ")}"
        next
      end

      department.update!(code: unit[:code], official_name: unit[:official_name])
    end

    CLASSIFIER.each do |unit|
      next unless unit[:parent]

      department = MigrationDepartment.find_by(code: unit[:code])
      parent = MigrationDepartment.find_by(code: unit[:parent])
      department&.update!(parent_id: parent&.id)
    end
  end

  def down
    MigrationDepartment.reset_column_information

    CLASSIFIER.select { |unit| unit[:create_name] }.each do |unit|
      department = MigrationDepartment.find_by(code: unit[:code], public_visible: false)
      next unless department
      next say("Se conserva #{department.acronym}: tiene usuarios asignados") if MigrationUser.exists?(department_id: department.id)

      MigrationDepartment.where(parent_id: department.id).update_all(parent_id: nil)
      department.delete
    end

    MigrationDepartment.update_all(code: nil, official_name: nil, parent_id: nil)
  end

  private

  def find_by_acronyms(acronyms)
    MigrationDepartment.where("LOWER(TRIM(acronym)) IN (?)", acronyms.map(&:downcase)).first
  end
end
