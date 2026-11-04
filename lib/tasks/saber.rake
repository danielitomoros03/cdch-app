namespace :saber do
  desc "Trae de Saber-UCV lo nuevo o modificado (OAI-PMH) y vuelve a vincular autores con docentes"
  task sync: :environment do
    Saber::Sync.call(full: false)
  end

  desc "Trae todo Saber-UCV (marca los borrados) y vuelve a vincular autores con docentes"
  task sync_full: :environment do
    Saber::Sync.call(full: true)
  end

  desc "Solo vuelve a vincular autores de Saber con docentes, sin cosechar"
  task match: :environment do
    result = Saber::AuthorMatcher.new.run
    puts "Vínculos: #{result.created} nuevos, #{result.removed} quitados, #{result.kept} sin cambio"
  end
end
