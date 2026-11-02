module Dashboard
  # Bitácora: quién hizo qué, cuándo y desde dónde. Solo lectura.
  class AuditLogsController < ApplicationController
    PER_PAGE = 25

    def index
      authorize! :read, AuditVersion
      @filters = params.permit(:actor, :category, :sensitive, :from, :to).to_h.symbolize_keys
      @actors = actor_options
      @entries = filtered_versions.newest_first.paginate(page: params[:page], per_page: PER_PAGE)
    end

    private

    def filtered_versions
      versions = AuditVersion.all
      # Los cambios en arbitrajes solo los ve quien puede leer arbitrajes.
      versions = versions.where.not(item_type: "PeerReview").or(versions.where(item_type: nil)) unless can?(:read, PeerReview)
      versions = AuditEntry.in_category(versions, @filters[:category])
      versions = versions.sensitive_only if @filters[:sensitive] == "1"
      versions = versions.by_actor(*@filters[:actor].split(":", 2)) if @filters[:actor].to_s.match?(/\A(User|Person):\d+\z/)
      from = parse_date(@filters[:from])
      to = parse_date(@filters[:to])
      versions = versions.between(from, to) if from || to
      versions
    end

    # Quienes aparecen en la bitácora, con el nombre de su última línea.
    def actor_options
      AuditVersion.where.not(actor_type: nil).group(:actor_type, :whodunnit).pluck(:actor_type, :whodunnit, Arel.sql("MAX(actor_label)"))
                  .map { |type, id, label| [ label, "#{type}:#{id}" ] }.sort_by(&:first)
    end

    def parse_date(value)
      Date.iso8601(value.to_s)
    rescue Date::Error
      nil
    end
  end
end
