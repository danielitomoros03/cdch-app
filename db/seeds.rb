# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

User.create!(email: "danielito.moros03@gmail.com", password: "123123", name: "Daniel", lastname: "Moros", number_phone: "04122539992", identification_number: "30035269")

# Create departments
departments_data = [
  { acronym: "DADA", name: "Departamentos de Apoyo al Desarrollo Académico", descriptionDepartment: "Encargado del apoyo y desarrollo académico en la Universidad Central de Venezuela." },
  { acronym: "DADI", name: "Departamentos de Apoyo al Desarrollo de la Investigación", descriptionDepartment: "Facilita y promueve el desarrollo de proyectos de investigación científica y humanística." },
  { acronym: "Publicaciones", name: "Relaciones y Publicaciones", descriptionDepartment: "Gestiona las publicaciones científicas, libros y materiales académicos del CDCH." },
  { acronym: "Saber UCV", name: "Departamento de Comunicación de la Tecnología e Innovación", descriptionDepartment: "Encargado de la comunicación, tecnología y innovación en la plataforma Saber UCV." },
  { acronym: "DEA", name: "Departamento de Evaluación y Acreditación", descriptionDepartment: "Evalúa y acredita proyectos de investigación y programas académicos." },
  { acronym: "DRHC", name: "Departamento de Recursos Humanos y Capacitación", descriptionDepartment: "Gestiona el personal y programas de capacitación para investigadores y administrativos." },
  { acronym: "DAF", name: "Departamento Administrativo y Financiero", descriptionDepartment: "Administra los recursos financieros y operaciones administrativas del CDCH." },
  { acronym: "DEIC", name: "Departamento de Ética e Integridad Científica", descriptionDepartment: "Vigila el cumplimiento ético e integridad en todas las actividades de investigación." }
]

departments_data.each do |dept|
  Department.find_or_create_by!(acronym: dept[:acronym]) do |d|
    d.name = dept[:name]
    d.descriptionDepartment = dept[:descriptionDepartment]
  end
end

puts "#{Department.count} departamentos estándar creados."
