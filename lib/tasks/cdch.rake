namespace :cdch do
  desc "Carga la base unificada del ETL (SQLITE=ruta; por defecto ../Data unificada/cdch_unificado.sqlite)"
  task import: :environment do
    if Rails.env.production? && ENV["FORCE"] != "1"
      abort "En producción se exige FORCE=1."
    end

    path = ENV.fetch("SQLITE") { Rails.root.join("..", "Data unificada", "cdch_unificado.sqlite") }
    Cdch::LegacyImport.new(path).call
  end
end
