# Estado de la cosecha de Saber-UCV, tal como lo deja Saber::Sync en storage/saber-estado.json.
# Lo muestran la Configuración general y el inicio del dashboard, con un aviso cuando algo anda mal:
# la cosecha falló, dejó de correr, o corre bien pero Saber no entrega nada nuevo (así se vio en
# noviembre de 2026 que el índice OAI de Saber estaba detenido desde julio).
module Saber
  class Status
    # La cosecha corre cada lunes; pasado este margen, la tarea programada no está corriendo.
    LATE_AFTER = 9.days
    # Saber recibe publicaciones por tandas, pero nunca pasó tanto tiempo sin ninguna.
    QUIET_AFTER = 30.days

    attr_reader :data

    def self.current
      data = Sync.status
      new(data) if data
    end

    def initialize(data)
      @data = data
    end

    def ok? = data["ok"] == true && !late?

    def failed? = data["ok"] != true

    def error = data["error"].presence

    def full? = data["full"] == true

    def items = data["items"].to_i

    def finished_at = time("finished_at")

    def newest_at = time("newest_datestamp")

    def late?
      finished_at.nil? || finished_at < LATE_AFTER.ago
    end

    def quiet?
      newest_at.present? && newest_at < QUIET_AFTER.ago
    end

    def quiet_days
      (Date.current - newest_at.to_date).to_i if newest_at
    end

    # Frases para quien lee el aviso; vacío cuando todo está bien.
    def warnings
      list = []
      list << "La última cosecha falló: #{error || 'sin detalle'}." if failed?
      list << "La cosecha no corre desde el #{I18n.l(finished_at.to_date, format: '%d/%m/%Y')}; debía correr cada lunes. Hay que revisar las tareas programadas del servidor." if late? && finished_at
      if quiet?
        list << "Saber no entrega publicaciones nuevas desde el #{I18n.l(newest_at.to_date, format: '%d/%m/%Y')} " \
                "(hace #{quiet_days} días). Puede que su índice OAI se haya detenido: conviene avisar al equipo de Saber-UCV."
      end
      list
    end

    private

    def time(key)
      Time.zone.parse(data[key].to_s)
    rescue ArgumentError
      nil
    end
  end
end
