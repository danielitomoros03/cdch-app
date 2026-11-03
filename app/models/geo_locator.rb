require "maxmind/db"

# Ubicación aproximada de una IP con la base libre DB-IP City Lite (CC BY 4.0), un archivo
# .mmdb que vive en el servidor, fuera del repo (GEOIP_DB o storage/geo), y que renueva
# cada mes script/server/cdch-respaldo. Sin el archivo no hay ubicación, y nunca se
# consulta un servicio externo.
module GeoLocator
  DEFAULT_PATH = Rails.root.join("storage/geo/dbip-city-lite.mmdb")
  LOCAL = "Red local".freeze

  class << self
    def lookup(ip)
      address = IPAddr.new(ip.to_s)
      return LOCAL if address.private? || address.loopback? || address.link_local?
      return unless reader

      cache.fetch(ip) { describe(reader.get(ip.to_s)) }
    rescue IPAddr::InvalidAddressError, MaxMind::DB::InvalidDatabaseError
      nil
    end

    private

    def describe(record)
      return unless record

      city = record.dig("city", "names", "en")
      region = record.dig("subdivisions", 0, "names", "en")
      country = record.dig("country", "names", "es")&.sub(/\s*\(.*\)\z/, "") || record.dig("country", "names", "en")
      [ city, (region unless region == city), country ].compact_blank.join(", ").presence
    end

    # El archivo se renueva cada mes en el servidor: si cambia, se vuelve a abrir.
    # Se revisa a lo sumo una vez por hora.
    def reader
      return @reader if @checked_at&.after?(1.hour.ago)

      @checked_at = Time.current
      path = ENV.fetch("GEOIP_DB", DEFAULT_PATH).to_s
      mtime = File.exist?(path) ? File.mtime(path) : nil
      if mtime != @mtime
        @mtime = mtime
        @reader = (MaxMind::DB.new(path, mode: MaxMind::DB::MODE_FILE) if mtime)
        cache.clear
      end
      @reader
    end

    def cache
      @cache ||= ActiveSupport::Cache::MemoryStore.new(size: 2.megabytes, expires_in: 1.day)
    end
  end
end
