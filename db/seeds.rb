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
puts "Usuario #{User.last.full_name} creado."

# Create departments
departments_data = [
  { acronym: "DADA", name: "Departamentos de Apoyo al Desarrollo Académico", description: "Encargado del apoyo y desarrollo académico en la Universidad Central de Venezuela." },
  { acronym: "DADI", name: "Departamentos de Apoyo al Desarrollo de la Investigación", description: "Facilita y promueve el desarrollo de proyectos de investigación científica y humanística." },
  { acronym: "Publicaciones", name: "Relaciones y Publicaciones", description: "Gestiona las publicaciones científicas, libros y materiales académicos del CDCH." },
  { acronym: "Saber UCV", name: "Departamento de Comunicación de la Tecnología e Innovación", description: "Encargado de la comunicación, tecnología y innovación en la plataforma Saber UCV." },
  { acronym: "DEA", name: "Departamento de Evaluación y Acreditación", description: "Evalúa y acredita proyectos de investigación y programas académicos." },
  { acronym: "DRHC", name: "Departamento de Recursos Humanos y Capacitación", description: "Gestiona el personal y programas de capacitación para investigadores y administrativos." },
  { acronym: "DAF", name: "Departamento Administrativo y Financiero", description: "Administra los recursos financieros y operaciones administrativas del CDCH." },
  { acronym: "DEIC", name: "Departamento de Ética e Integridad Científica", description: "Vigila el cumplimiento ético e integridad en todas las actividades de investigación." }
]

departments_data.each do |dept|
  Department.find_or_create_by!(acronym: dept[:acronym]) do |d|
    d.name = dept[:name]
    d.description = dept[:description]
  end
end

puts "#{Department.count} departamentos estándar creados."

# Create institution data
Institution.find_or_create_by!(name: "Centro de Desarrollo Científico y Humanístico") do |institution|
  institution.acronym = "CDCH"
  institution.address = "Quinta Silenia, Urb. La Floresta, Caracas 1040, Venezuela."
  institution.primary_phone = "+58 212 6052860"
  institution.secondary_phone = "+58 212 6052861"
  institution.primary_email = "cdch@ucv.ve"
  institution.secondary_email = "info@cdch.ucv.ve"
  institution.business_hours = "Lunes a Viernes: 8:00 AM - 4:00 PM"
  institution.mission = "El Centro de Desarrollo Científico y Humanístico (CDCH) de la UCV tiene como misión promover, coordinar y apoyar el desarrollo de la investigación científica y humanística en la institución, contribuyendo al avance del conocimiento y al fortalecimiento de la formación académica de la comunidad universitaria."
  institution.vission = "Ser el centro de referencia nacional e internacional en el desarrollo de la investigación científica y humanística, reconocido por su excelencia académica, innovación y contribución al desarrollo sostenible de Venezuela."
  institution.description = "El CDCH es la instancia responsable de promover, coordinar y apoyar el desarrollo de la investigación científica y humanística en la UCV."
  institution.twitter_url = "https://twitter.com/CDCH_UCV"
  institution.facebook_url = "https://facebook.com/CDCH.UCV"
  institution.instagram_url = "https://instagram.com/cdch_ucv"
  institution.linkedin_url = "https://linkedin.com/company/cdch-ucv"
  institution.threads_url = "https://threads.net/@cdch_ucv"
  institution.director_name = "Dr. José Antonio Rivas"
  institution.director_email = "director@cdch.ucv.ve"
  institution.founded_year = 1970
  institution.description = "Descripción detallada del Centro de Desarrollo Científico y Humanístico de la UCV."
end

puts "Datos institucionales estándar del CDCH creados."

# Create calls
calls_data = [
  {
    title: "Convocatoria 2026 - Proyectos Individuales",
    short_description: "Financiamiento para proyectos de investigación individuales en todas las áreas del conocimiento. Monto máximo: Bs. 50.000",
    large_description: "<p>Esta convocatoria está dirigida a investigadores individuales de la Universidad Central de Venezuela que deseen desarrollar proyectos de investigación en cualquier área del conocimiento. Se financiarán hasta Bs. 50.000 por proyecto.</p><p>Requisitos: Ser docente o investigador activo de la UCV, presentar un proyecto innovador y tener experiencia previa en investigación.</p>",
    start_date: Date.new(2026, 1, 1),
    end_date: Date.new(2026, 4, 30),
    active: true,
    type: :Call
  },
  {
    title: "Convocatoria 2026 - Proyectos Grupales",
    short_description: "Financiamiento para proyectos de investigación grupales con impacto interdisciplinario. Monto máximo: Bs. 150.000",
    large_description: "<p>Convocatoria para equipos de investigación interdisciplinarios. Se busca fomentar la colaboración entre diferentes áreas del conocimiento para abordar problemas complejos.</p><p>Monto máximo: Bs. 150.000. Se requiere al menos 3 investigadores de diferentes departamentos.</p>",
    start_date: Date.new(2026, 1, 15),
    end_date: Date.new(2026, 5, 15),
    active: true,
    type: :Call
  },
  {
    title: "Convocatoria 2025 - Proyectos Emergentes",
    short_description: "Proyectos de investigación sobre temas de relevancia nacional e internacional que han sido cerrados.",
    large_description: "<p>Esta convocatoria anterior financió proyectos emergentes en temas críticos para Venezuela y el mundo. Ya cerró el 31 de diciembre de 2025.</p>",
    start_date: Date.new(2025, 6, 1),
    end_date: Date.new(2025, 12, 31),
    active: false,
    type: :Call
  }
]

calls_data.each do |call_data|
  Call.find_or_create_by!(title: call_data[:title]) do |call|
    call.short_description = call_data[:short_description]
    call.large_description = call_data[:large_description]
    call.start_date = call_data[:start_date]
    call.end_date = call_data[:end_date]
    call.active = call_data[:active]
    call.type = call_data[:type]
  end
end

puts "#{Call.count} convocatorias creadas."
