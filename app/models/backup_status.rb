# Estado de los respaldos automáticos, tal como lo deja script/server/cdch-respaldo en
# storage/respaldo-estado.json (la carpeta storage del servidor está montada en la app).
# La Configuración general lo muestra para que la DTIC vea si un respaldo falló.
class BackupStatus
  PATH = Rails.root.join("storage/respaldo-estado.json")
  # El respaldo corre cada día; pasado este margen, algo anda mal aunque no haya error.
  STALE_AFTER = 36.hours

  attr_reader :data

  def self.current
    new(JSON.parse(File.read(PATH))) if File.exist?(PATH)
  rescue JSON::ParserError
    new("error" => "El archivo de estado de los respaldos está dañado.")
  end

  def initialize(data)
    @data = data
  end

  def ok?
    error.blank? && last_backup_at.present? && !stale?
  end

  def stale?
    last_backup_at.nil? || last_backup_at < STALE_AFTER.ago
  end

  def error
    data["error"].presence
  end

  def last_backup_at = time("db_at")

  def last_files_at = time("files_at")

  def geo_updated_at = time("geo_at")

  def db_size = data["db_size"].to_i

  def daily_count = data["daily_count"].to_i

  def monthly_count = data["monthly_count"].to_i

  private

  def time(key)
    Time.zone.parse(data[key].to_s)
  rescue ArgumentError
    nil
  end
end
