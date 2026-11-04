module Saber
  # Cosecha y vinculación juntas, como las corren las tareas programadas (app.json).
  # Deja el resultado en el log y en storage/saber-estado.json, que muestra la configuración general.
  module Sync
    STATUS_PATH = Rails.root.join("storage/saber-estado.json")

    module_function

    def call(full:, harvester: Harvester.new, matcher: AuthorMatcher.new, out: $stdout)
      started_at = Time.current
      harvest = harvester.run(full: full)
      links = matcher.run
      status = {
        ok: true, full: full, finished_at: Time.current.iso8601, seconds: (Time.current - started_at).round,
        saved: harvest.saved, deleted: harvest.deleted, created: links.created, removed: links.removed,
        items: SaberItem.current.count, newest_datestamp: SaberItem.maximum(:datestamp)&.iso8601
      }
      write(status)
      out.puts "Saber: #{harvest.saved} registros traídos, #{harvest.deleted} marcados como borrados; " \
               "vínculos: #{links.created} nuevos, #{links.removed} quitados (#{status[:seconds]} s)"
      status
    rescue StandardError => e
      write(ok: false, full: full, finished_at: Time.current.iso8601, error: e.message.truncate(300))
      raise
    end

    def write(status)
      FileUtils.mkdir_p(STATUS_PATH.dirname)
      File.write(STATUS_PATH, JSON.pretty_generate(status))
    end

    def status
      JSON.parse(File.read(STATUS_PATH)) if File.exist?(STATUS_PATH)
    rescue JSON::ParserError
      nil
    end
  end
end
