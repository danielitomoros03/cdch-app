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
puts "Usuario #{user.last.full_name} creado."

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

# Create institution data
Institution.find_or_create_by!(name: "Centro de Desarrollo Científico y Humanístico") do |institution|
  institution.acronym = "CDCH"
  institution.address = "Ciudad Universitaria, Caracas 1040, Venezuela"
  institution.primary_phone = "+58 212 6052860"
  institution.secondary_phone = "+58 212 6052861"
  institution.primary_email = "cdch@ucv.ve"
  institution.secondary_email = "info@cdch.ucv.ve"
  institution.business_hours = "Lunes a Viernes: 8:00 AM - 4:00 PM"
  institution.mission = "El Centro de Desarrollo Científico y Humanístico (CDCH) de la Universidad Central de Venezuela tiene como misión promover, coordinar y apoyar el desarrollo de la investigación científica y humanística en la institución, contribuyendo al avance del conocimiento y al fortalecimiento de la formación académica de la comunidad universitaria."
  institution.vission = "Ser el centro de referencia nacional e internacional en el desarrollo de la investigación científica y humanística, reconocido por su excelencia académica, innovación y contribución al desarrollo sostenible de Venezuela."
  institution.description = "El CDCH es la instancia responsable de promover, coordinar y apoyar el desarrollo de la investigación científica y humanística en la Universidad Central de Venezuela. Fue creado para fortalecer la capacidad investigativa de la institución y contribuir al avance del conocimiento en diversas áreas del saber."
  institution.twitter_url = "https://twitter.com/CDCH_UCV"
  institution.facebook_url = "https://facebook.com/CDCH.UCV"
  institution.instagram_url = "https://instagram.com/cdch_ucv"
  institution.linkedin_url = "https://linkedin.com/company/cdch-ucv"
  institution.threads_url = "https://threads.net/@cdch_ucv"
  institution.director_name = "Dr. José Antonio Rivas"
  institution.director_email = "director@cdch.ucv.ve"
  institution.founded_year = 1970
end

puts "Datos institucionales estándar del CDCH creados."
