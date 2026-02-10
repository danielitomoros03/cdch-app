# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create departments
departments_data = [
  { organize: 0, acronym: "DADA", name: "Departamentos de Apoyo al Desarrollo Académico", description: "Promover la disponibilidad y asignación eficiente de recursos financieros destinados a la formación y actualización del capital intelectual, mediante el establecimiento de normativas y estándares de calidad que aseguren la competitividad profesional y contribuyan al desarrollo estratégico nacional." },
  { organize: 1, acronym: "DADI", name: "Departamentos de Apoyo al Desarrollo de la Investigación", description: "Potenciar la producción científica y académica de la UCV mediante la gestión estratégica de ayudas financieras y el fortalecimiento de la infraestructura investigativa, con el fin de elevar la calidad de la enseñanza y posicionar la generación de conocimiento como motor de productividad institucional." },
  { organize: 2, acronym: "Publicaciones", name: "Departamento de Relaciones y Publicaciones", description: "Potenciar la producción científica y académica de la UCV mediante la gestión estratégica de ayudas financieras y el fortalecimiento de la infraestructura investigativa, con el fin de elevar la calidad de la enseñanza y posicionar la generación de conocimiento como motor de productividad institucional." },
  { organize: 3, acronym: "DAPDA - Saber UCV", name: "Departamento de Apoyo a la Preservación y Difusión Académica", description: "Administrar, preservar y difundir el patrimonio intelectual de la institución a través del Repositorio Institucional 'Saber UCV', garantizando el acceso abierto a la producción científica y académica (revistas, libros y artículos) bajo estándares internacionales de calidad, para consolidar el liderazgo de la universidad como el principal referente de conocimiento del país." },
  { organize: 4, acronym: "DTIC", name: "Departamento de Tecnología, Información y Comunicaciones", description: "Gestionar y optimizar la infraestructura tecnológica y los sistemas de información del CDCH, mediante la implementación de soluciones de vanguardia, el desarrollo de software a medida y un soporte técnico proactivo, con el fin de garantizar la eficiencia operativa, la seguridad de la data y la excelencia en los servicios digitales ofrecidos a la comunidad académica y administrativa." },
  { organize: 5, acronym: "Archivo y Correspondencia", name: "Departamento de Archivo y Correspondencia", description: "Gestionar el flujo integral de la información y el acervo documental del CDCH, mediante la administración técnica de la correspondencia, la digitalización de procesos y el resguardo del patrimonio bibliográfico, con el fin de garantizar la trazabilidad, la disponibilidad oportuna de la información y el soporte estratégico para la toma de decisiones institucionales." },
  { organize: 6, acronym: "Administración", name: "Departamento de Administración", description: "Garantizar la sostenibilidad financiera y operativa del CDCH mediante la administración eficiente de los recursos, la transparencia en los procesos de adquisición y el estricto cumplimiento del marco legal vigente, con el fin de asegurar el abastecimiento oportuno y la integridad del patrimonio institucional en apoyo a la actividad científica y académica." },
  { organize: 7, acronym: "Compras", name: "Departamento de Compras", description: "Gestionar los procesos de procura de bienes, servicios y obras del CDCH, garantizando el abastecimiento oportuno y la optimización de los recursos financieros a través de una planificación estratégica y el estricto cumplimiento del marco legal de contrataciones públicas, para asegurar la continuidad operativa de las unidades académicas y administrativas." }
]

departments_data.each do |dept|
  Department.find_or_create_by!(acronym: dept[:acronym]) do |d|
    d.name = dept[:name]
    d.organize = dept[:organize]
    d.description = dept[:description]
  end
end

puts "#{Department.count} departamentos estándar creados."

# Create JobTitles
job_titles_data = [
  { name: "Desarrollador", role: :Superadmin },
  { name: "Director", role: :Superadmin },
  { name: "Sub-director", role: :Superadmin },
  { name: "Coordinador", role: :Coordinador },
  { name: "Investigador", role: :Regular },
  { name: "Personal Administrativo", role: :Regular }
]

job_titles_data.each do |job_title|
  JobTitle.find_or_create_by!(name: job_title[:name]) do |jt|
    jt.role = job_title[:role]
  end
end

puts "#{JobTitle.count} cargos estándares creados."

User.create!(email: "danielito.moros03@gmail.com", password: "123123", department_id: 1, job_title_id: JobTitle.find_by(name: "Desarrollador").id, name: "Daniel", lastname: "Moros", number_phone: "04122539992", identification_number: "30035269")
puts "Usuario #{User.last.full_name} creado."

User.create!(email: "director@ucv.ve", password: "123123", department_id: 1, job_title_id: JobTitle.find_by(name: "Director").id, name: "Juana", lastname: "García", number_phone: "0416123120", identification_number: "12312311")
puts "Usuario #{User.last.role} creado."

User.create!(email: "subdirector@ucv.ve", password: "123123", department_id: 1, job_title_id: JobTitle.find_by(name: "Sub-director").id, name: "Carlos A.", lastname: "Saavedra A.", number_phone: "04143661978", identification_number: "12312312")
puts "Usuario #{User.last.full_name} creado."

User.create!(email: "coordinador@ucv.ve", password: "123123", department_id: 2, job_title_id: JobTitle.find_by(name: "Coordinador").id, name: "Virginia", lastname: "Plazas", number_phone: "0416123123", identification_number: "12312313")
puts "Usuario #{User.last.role} creado."

User.create!(email: "administrativo@ucv.ve", password: "123123", department_id: 2, job_title_id: JobTitle.find_by(name: "Personal Administrativo").id, name: "Alexander", lastname: "Contreras", number_phone: "0416123124", identification_number: "12312314")
puts "Usuario #{User.last.role} creado."

User.create!(email: "regular@ucv.ve", password: "123123", department_id: 3x|, job_title_id: JobTitle.find_by(name: "Investigador").id, name: "Josué", lastname: "Castillo", number_phone: "0416123125", identification_number: "12312315")
puts "Usuario #{User.last.role} creado."


# Create institution data
Institution.find_or_create_by!(name: "Consejo de Desarrollo Científico y Humanístico") do |institution|
  institution.acronym = "CDCH"
  institution.address = "Quinta Silenia, Urb. La Floresta, Caracas 1040, Venezuela."
  institution.primary_phone = "+58 212 2871325"
  institution.secondary_phone = "+58 212 6052861"
  institution.primary_email = "cdch@ucv.ve"
  institution.secondary_email = "ucv.cdch.coordinacion@gmail.com"
  institution.business_hours = "Lunes a Viernes: 8:00 AM - 4:00 PM"
  institution.mission = "El Consejo de Desarrollo Científico y Humanístico (CDCH) de la UCV tiene como misión promover, coordinar y apoyar el desarrollo de la investigación científica y humanística en la institución, contribuyendo al avance del conocimiento y al fortalecimiento de la formación académica de la comunidad universitaria."
  institution.vission = "Ser el centro de referencia nacional e internacional en el desarrollo de la investigación científica y humanística, reconocido por su excelencia académica, innovación y contribución al desarrollo sostenible de Venezuela."
  institution.description = "El CDCH es la instancia responsable de promover, coordinar y apoyar el desarrollo de la investigación científica y humanística en la UCV."
  institution.twitter_url = "https://twitter.com/CDCH_UCV"
  institution.facebook_url = "https://facebook.com/CDCH.UCV"
  institution.instagram_url = "https://instagram.com/cdch_ucv"
  institution.linkedin_url = "https://linkedin.com/company/cdch-ucv"
  institution.threads_url = "https://threads.net/@cdch_ucv"
  institution.director_name = "Dra. María Rodríguez"
  institution.director_primary_email = "maria.rodriguez@ucv.ve"
  institution.director_secondary_email = "mariarodriguezchemical@gmail.com"
  institution.subdirector_name = "MSc. Carlos A. Saavedra A."
  institution.subdirector_primary_email = "carlos.saavedra@ucv.ve"
  institution.subdirector_secondary_email = "c.saavedra.cdch@gmail.com"
  institution.founded_year = 1958
  institution.history = "<div><strong>Nuestra Trayectoria: Legado y Futuro de la Excelencia Académica<br></strong><br></div><div><strong>Fundados en la Visión de un País</strong> El <strong>28 de junio de 1958</strong>, bajo el liderazgo del Rector <strong>Dr. Francisco de Venanzi</strong>, nació esta institución con una misión clara: ser el motor del desarrollo científico y humanístico de la Universidad Central de Venezuela. Lo que comenzó como un proyecto de vanguardia, se ha consolidado en más de seis décadas de labor ininterrumpida.<br><br></div><div><strong>Impacto y Compromiso</strong> No solo financiamos proyectos; impulsamos el conocimiento. Hemos sido el puente para la formación de miles de investigadores a nivel de postgrado y el soporte de hallazgos que han transformado la realidad técnica y social de Venezuela. Nuestra historia es la historia de la excelencia en la UCV.<br><br></div><div><strong>Evolución Estratégica</strong> Para responder a los desafíos del siglo XXI, nos hemos transformado:<br><br></div><ul><li><strong>2013:</strong> Evolucionamos de Gerencia a <strong>Dirección</strong>, fortaleciendo nuestra autoridad institucional.<br><br></li><li><strong>2025:</strong> Optimizamos nuestra estructura para ser más ágiles. Elevamos el nivel de nuestras operaciones y colocamos a la <strong>Ciencia, Tecnología e Innovación</strong> en el centro de nuestra ejecución operativa.</li></ul>"
end

puts "Datos institucionales estándar del CDCH creados."

publications_data = [
  { kind: "Libro", title: "Investigación Científica en Venezuela", author_name: "Dr. Juan Pérez", date_publication: Date.new(2024, 1, 15), description: "Una exploración profunda del estado actual de la investigación científica en el contexto venezolano." },
  { kind: "Revista", title: "Revista de Ciencias Sociales Vol. 45", author_name: "Varios autores", date_publication: Date.new(2024, 1, 15), description: "Edición especial dedicada a los estudios contemporáneos en ciencias sociales." },
  { kind: "Articulo", title: "Avances en Biotecnología Aplicada", author_name: "Dra. María González", date_publication: Date.new(2024, 1, 15), description: "Investigación sobre las últimas innovaciones en biotecnología médica." },
  { kind: "Libro", title: "Historia de la UCV: 300 Años", author_name: "Prof. Carlos Rodríguez", date_publication: Date.new(2023, 1, 15), description: "Recorrido histórico por los tres siglos de la Universidad Central de Venezuela." },
  { kind: "Revista", title: "Acta Científica Venezolana Vol. 74", author_name: "Varios autores", date_publication: Date.new(2023, 1, 15), description: "Publicación trimestral de investigaciones en ciencias exactas y naturales." },
  { kind: "Tesis", title: "Innovación Tecnológica en Educación", author_name: "MSc. Ana Martínez", date_publication: Date.new(2023, 1, 15), description: "Tesis doctoral sobre la implementación de tecnologías en el aula." }
]

publications_data.each do |pub|
  Publication.find_or_create_by!(title: pub[:title]) do |p|
    p.kind = pub[:kind]
    p.author_name = pub[:author_name]
    p.date_publication = pub[:date_publication]
    p.description = pub[:description]
  end
end

puts "#{Publication.count} publicaciones creadas."

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
    description: "El Consejo de Desarrollo Científico y Humanístico (CDCH) de la UCV anuncia la apertura de su convocatoria anual para proyectos de investigación individuales y grupales.",
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
    description: "El Consejo de Desarrollo Científico y Humanístico (CDCH) de la UCV anuncia la apertura de su convocatoria anual para proyectos de investigación individuales y grupales.",
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
    description: "El Consejo de Desarrollo Científico y Humanístico (CDCH) de la UCV anuncia la apertura de su convocatoria anual para proyectos de investigación individuales y grupales.",
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
    description: "El Consejo de Desarrollo Científico y Humanístico (CDCH) de la UCV anuncia la apertura de su convocatoria anual para proyectos de investigación individuales y grupales.",
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

# Create announcements
announcements_data = [
  {
    content: "<p>El CDCH invita a todos los investigadores de la UCV a participar en la convocatoria 2026, que ofrece financiamiento para proyectos innovadores en diversas áreas del conocimiento. La fecha límite para la presentación de propuestas es el 30 de abril de 2026.</p><p>Para más información, visite el sitio web oficial del CDCH.</p>",
    is_active: true
  },
  {
    content: "<p>El CDCH invita a todos los investigadores de la UCV a participar en la convocatoria 2026, que ofrece financiamiento para proyectos innovadores en diversas áreas del conocimiento. La fecha límite para la presentación de propuestas es el 30 de abril de 2026.</p><p>Para más información, visite el sitio web oficial del CDCH.</p>",
    is_active: false
  }
]

announcements.each do |announcement_data|
  Announcement.find_or_create_by!(content: announcement_data[:content]) do |announcement|
    announcement.is_active = announcement_data[:is_active]
  end
end

puts "#{Announcement.count} announcementos creados."