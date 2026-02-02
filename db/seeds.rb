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

# Create minutes
minutes_data = [
  {
    title: "Acta de Directorio - Reunión Ordinaria",
    day: Date.new(2024, 1, 15),
    description: "Reunión ordinaria para discutir presupuesto anual y actividades de investigación.",
    content: "<p>Acta correspondiente a la reunión ordinaria del directorio celebrada el 15 de enero de 2024. Se discutieron temas relacionados con el presupuesto anual y las actividades de investigación.</p>"
  },
  {
    title: "Acta de Directorio - Reunión Extraordinaria",
    day: Date.new(2023, 12, 28),
    description: "Reunión extraordinaria para abordar asuntos urgentes sobre renovación de convenios.",
    content: "<p>Acta de la reunión extraordinaria del directorio realizada el 28 de diciembre de 2023. Se abordaron asuntos urgentes sobre la renovación de convenios.</p>"
  },
  {
    title: "Acta de Directorio - Reunión Ordinaria",
    day: Date.new(2023, 11, 20),
    description: "Evaluación de proyectos en curso y avances en investigación.",
    content: "<p>Acta correspondiente a la reunión ordinaria del directorio celebrada el 20 de noviembre de 2023. Evaluación de proyectos en curso.</p>"
  },
  {
    title: "Acta de Directorio - Reunión Ordinaria",
    day: Date.new(2023, 10, 15),
    description: "Planificación de actividades para el próximo trimestre.",
    content: "<p>Acta correspondiente a la reunión ordinaria del directorio celebrada el 15 de octubre de 2023. Planificación de actividades para el próximo trimestre.</p>"
  },
  {
    title: "Acta de Directorio - Reunión Extraordinaria",
    day: Date.new(2023, 9, 5),
    description: "Discusión sobre cambios en la normativa interna.",
    content: "<p>Acta de la reunión extraordinaria del directorio realizada el 5 de septiembre de 2023. Discusión sobre cambios en la normativa interna.</p>"
  },
  {
    title: "Acta de Directorio - Reunión Ordinaria",
    day: Date.new(2023, 8, 18),
    description: "Revisión de informes de investigación y resultados.",
    content: "<p>Acta correspondiente a la reunión ordinaria del directorio celebrada el 18 de agosto de 2023. Revisión de informes de investigación.</p>"
  },
  {
    title: "Acta de Directorio - Reunión Ordinaria",
    day: Date.new(2023, 7, 10),
    description: "Aprobación de nuevos proyectos de investigación.",
    content: "<p>Acta correspondiente a la reunión ordinaria del directorio celebrada el 10 de julio de 2023. Aprobación de nuevos proyectos.</p>"
  },
  {
    title: "Acta de Directorio - Reunión Extraordinaria",
    day: Date.new(2023, 6, 22),
    description: "Temas administrativos y operativos.",
    content: "<p>Acta de la reunión extraordinaria del directorio realizada el 22 de junio de 2023. Temas administrativos.</p>"
  },
  {
    title: "Acta de Directorio - Reunión Ordinaria",
    day: Date.new(2023, 5, 15),
    description: "Evaluación financiera y presupuestaria.",
    content: "<p>Acta correspondiente a la reunión ordinaria del directorio celebrada el 15 de mayo de 2023. Evaluación financiera.</p>"
  },
  {
    title: "Acta de Directorio - Reunión Ordinaria",
    day: Date.new(2023, 4, 20),
    description: "Planificación estratégica para el año académico.",
    content: "<p>Acta correspondiente a la reunión ordinaria del directorio celebrada el 20 de abril de 2023. Planificación estratégica.</p>"
  }
]

minutes_data.each do |minute_data|
  Minute.find_or_create_by!(title: minute_data[:title], day: minute_data[:day]) do |minute|
    minute.description = minute_data[:description]
    minute.content = minute_data[:content]
    # Simular attachment
    if minute_data[:title].include?("Extraordinaria")
      dummy_file = StringIO.new("Contenido del acta en PDF simulado.")
      dummy_file.class.class_eval { attr_accessor :original_filename, :content_type }
      dummy_file.original_filename = "acta_#{minute.day.strftime('%Y%m%d')}.pdf"
      dummy_file.content_type = "application/pdf"
      minute.attachment_minute.attach(io: dummy_file, filename: dummy_file.original_filename, content_type: dummy_file.content_type)
    end
  end
end

puts "#{Minute.count} actas creadas."

# Create calls
calls_data = [
  {
    title: "Convocatoria 2026 - Proyectos Individuales",
    short_description: "Financiamiento para proyectos de investigación individuales en todas las áreas del conocimiento. Monto máximo: Bs. 50.000",
    large_description: "<p>Esta convocatoria está dirigida a investigadores individuales de la Universidad Central de Venezuela que deseen desarrollar proyectos de investigación en cualquier área del conocimiento. Se financiarán hasta Bs. 50.000 por proyecto.</p><p>Requisitos: Ser docente o investigador activo de la UCV, presentar un proyecto innovador y tener experiencia previa en investigación.</p>",
    start_date: Date.new(2026, 1, 1),
    end_date: Date.new(2026, 4, 30),
    active: true,
    kind: :Call
  },
  {
    title: "Convocatoria 2026 - Proyectos Grupales",
    short_description: "Financiamiento para proyectos de investigación grupales con impacto interdisciplinario. Monto máximo: Bs. 150.000",
    large_description: "<p>Convocatoria para equipos de investigación interdisciplinarios. Se busca fomentar la colaboración entre diferentes áreas del conocimiento para abordar problemas complejos.</p><p>Monto máximo: Bs. 150.000. Se requiere al menos 3 investigadores de diferentes departamentos.</p>",
    start_date: Date.new(2026, 1, 15),
    end_date: Date.new(2026, 5, 15),
    active: true,
    kind: :Call
  },
  {
    title: "Convocatoria 2025 - Proyectos Emergentes",
    short_description: "Proyectos de investigación sobre temas de relevancia nacional e internacional que han sido cerrados.",
    large_description: "<p>Esta convocatoria anterior financió proyectos emergentes en temas críticos para Venezuela y el mundo. Ya cerró el 31 de diciembre de 2025.</p>",
    start_date: Date.new(2025, 6, 1),
    end_date: Date.new(2025, 12, 31),
    active: false,
    kind: :Call
  }
]

calls_data.each do |call_data|
  Call.find_or_create_by!(title: call_data[:title]) do |call|
    call.short_description = call_data[:short_description]
    call.large_description = call_data[:large_description]
    call.start_date = call_data[:start_date]
    call.end_date = call_data[:end_date]
    call.active = call_data[:active]
    call.kind = call_data[:kind]
  end
end

puts "#{Call.count} convocatorias creadas."


# Create events
events_data = [
  {
    title: "Convocatoria de Proyectos de Investigación 2026",
    description: "El Centro de Desarrollo Científico y Humanístico (CDCH) de la UCV anuncia la apertura de su convocatoria anual para proyectos de investigación individuales y grupales.",
    content: "<p>El CDCH invita a todos los investigadores de la UCV a participar en la convocatoria 2026, que ofrece financiamiento para proyectos innovadores en diversas áreas del conocimiento. La fecha límite para la presentación de propuestas es el 30 de abril de 2026.</p><p>Para más información, visite el sitio web oficial del CDCH.</p>",
    day: Date.new(2024, 6, 1),
    kind: 0,
    show_in: false,
    active: true,
    start_time: Time.new(2024, 6, 1, 9, 0, 0),
    end_time: Time.new(2024, 6, 1, 17, 0, 0),
    location: "Auditorio Principal del CDCH"
  },
  {
    title: "Seminario de Investigación Científica 2026",
    description: "El Centro de Desarrollo Científico y Humanístico (CDCH) de la UCV anuncia la apertura de su convocatoria anual para proyectos de investigación individuales y grupales.",
    content: "<p>El CDCH invita a todos los investigadores de la UCV a participar en la convocatoria 2026, que ofrece financiamiento para proyectos innovadores en diversas áreas del conocimiento. La fecha límite para la presentación de propuestas es el 30 de abril de 2026.</p><p>Para más información, visite el sitio web oficial del CDCH.</p>",
    day: Date.new(2024, 6, 1),
    kind: 0,
    show_in: true,
    active: true,
    start_time: Time.new(2024, 6, 1, 9, 0, 0),
    end_time: Time.new(2024, 6, 1, 17, 0, 0),
    location: "Auditorio Principal del CDCH"
  },
  {
    title: "Jornada de Innovación y Tecnología",
    description: "El Centro de Desarrollo Científico y Humanístico (CDCH) de la UCV anuncia la apertura de su convocatoria anual para proyectos de investigación individuales y grupales.",
    content: "<p>El CDCH invita a todos los investigadores de la UCV a participar en la convocatoria 2026, que ofrece financiamiento para proyectos innovadores en diversas áreas del conocimiento. La fecha límite para la presentación de propuestas es el 30 de abril de 2026.</p><p>Para más información, visite el sitio web oficial del CDCH.</p>",
    day: Date.new(2024, 6, 1),
    kind: 2,
    show_in: true,
    active: true,
    start_time: Time.new(2024, 6, 1, 9, 0, 0),
    end_time: Time.new(2024, 6, 1, 17, 0, 0),
    location: "Auditorio Principal del CDCH"
  },
  {
    title: "Foro de Debate Académico",
    description: "El Centro de Desarrollo Científico y Humanístico (CDCH) de la UCV anuncia la apertura de su convocatoria anual para proyectos de investigación individuales y grupales.",
    content: "<p>El CDCH invita a todos los investigadores de la UCV a participar en la convocatoria 2026, que ofrece financiamiento para proyectos innovadores en diversas áreas del conocimiento. La fecha límite para la presentación de propuestas es el 30 de abril de 2026.</p><p>Para más información, visite el sitio web oficial del CDCH.</p>",
    day: Date.new(2024, 6, 1),
    kind: 3,
    show_in: true,
    active: true,
    start_time: Time.new(2024, 6, 1, 9, 0, 0),
    end_time: Time.new(2024, 6, 1, 17, 0, 0),
    location: "Auditorio Principal del CDCH"
  }
]
events_data.each do |event_data|
  Event.find_or_create_by!(title: event_data[:title], kind: event_data[:kind]) do |event|
    event.description = event_data[:description]
    event.content = event_data[:content]
    event.day = event_data[:day]
    event.show_in = event_data[:show_in]
    event.active = event_data[:active]
    event.start_time = event_data[:start_time]
    event.end_time = event_data[:end_time]
    event.location = event_data[:location]
  end
end

puts "#{Event.count} eventos creados."