require "net/http"

module Saber
  # Cosecha los metadatos públicos de Saber-UCV por OAI-PMH (formato `dim` de DSpace, que
  # conserva calificadores como dc.contributor.author) y los guarda en SaberItem.
  #
  # Solo lee, una página a la vez y con una pausa entre páginas para no cargar el servidor.
  # - Incremental: pide lo agregado o modificado desde el último `datestamp` guardado.
  # - Completa (`full: true`): trae todo y marca como borrado lo que ya no aparece, porque el
  #   OAI de Saber no garantiza avisar de los borrados (deletedRecord "transient").
  class Harvester
    BASE_URL = "https://saber.ucv.ve/oai/request".freeze
    USER_AGENT = "CDCH-UCV cdch-app (cosecha OAI-PMH)".freeze
    OAI = "http://www.openarchives.org/OAI/2.0/".freeze
    DIM = "http://www.dspace.org/xmlns/dspace/dim".freeze
    EMAIL = /[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}/
    DOI = %r{\b(10\.\d{4,9}/[^\s"<>]+)}i

    Result = Struct.new(:pages, :saved, :deleted, keyword_init: true)

    class Error < StandardError; end

    # `ip`: dirección del servidor de Saber para cuando su nombre no resuelve en el DNS (variable
    # SABER_IP en Dokku). Se conecta a esa IP pero se presenta como saber.ucv.ve, así que el
    # certificado se sigue verificando. Se quita cuando el DNS vuelva a funcionar.
    def initialize(base_url: BASE_URL, pause: 1.5, logger: Rails.logger, http: nil, ip: ENV["SABER_IP"].presence)
      @base_url = base_url
      @ip = ip
      @pause = pause
      @logger = logger
      @http = http || method(:fetch)
    end

    def run(full: false)
      started_at = Time.current
      harvest_collections
      params = { verb: "ListRecords", metadataPrefix: "dim" }
      since = !full && SaberItem.maximum(:datestamp)
      params[:from] = (since - 1.day).utc.strftime("%Y-%m-%d") if since
      result = Result.new(pages: 0, saved: 0, deleted: 0)

      each_page(params) do |doc|
        result.pages += 1
        doc.xpath("//o:record", "o" => OAI).each do |record|
          save(record, started_at)
          result.saved += 1
        end
        @logger.info("[saber] página #{result.pages}: #{result.saved} registros")
      end

      if full
        result.deleted = SaberItem.current.where("seen_at IS NULL OR seen_at < ?", started_at).update_all(deleted: true, updated_at: Time.current)
      end
      result
    end

    private

    def harvest_collections
      each_page(verb: "ListSets") do |doc|
        rows = doc.xpath("//o:set", "o" => OAI).map do |set|
          { spec: set.at_xpath("o:setSpec", "o" => OAI).text, name: set.at_xpath("o:setName", "o" => OAI)&.text }
        end
        SaberCollection.upsert_all(rows, unique_by: :spec) if rows.any?
      end
    end

    def each_page(params)
      loop do
        doc = Nokogiri::XML(@http.call(params))
        error = doc.at_xpath("//o:error", "o" => OAI)
        if error
          return if error["code"] == "noRecordsMatch"

          raise Error, "OAI respondió #{error['code']}: #{error.text}"
        end
        yield doc
        token = doc.at_xpath("//o:resumptionToken", "o" => OAI)&.text
        break if token.blank?

        params = { verb: params[:verb], resumptionToken: token }
        sleep @pause
      end
    end

    def fetch(params, attempts: 5)
      uri = URI(@base_url)
      uri.query = URI.encode_www_form(params)
      attempts.times do |attempt|
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == "https"
        http.ipaddr = @ip if @ip
        http.open_timeout = 30
        http.read_timeout = 120
        response = http.start { |connection| connection.get(uri.request_uri, "User-Agent" => USER_AGENT) }
        return response.body if response.is_a?(Net::HTTPSuccess)

        raise Error, "HTTP #{response.code}"
      rescue StandardError => e
        raise Error, "Saber no respondió tras #{attempts} intentos: #{e.message}" if attempt == attempts - 1

        @logger.warn("[saber] #{e.message}; reintento")
        sleep 10 * (attempt + 1)
      end
    end

    def save(record, seen_at)
      header = record.at_xpath("o:header", "o" => OAI)
      handle = header.at_xpath("o:identifier", "o" => OAI).text.split(":").last
      item = SaberItem.find_or_initialize_by(handle: handle)
      item.datestamp = Time.zone.parse(header.at_xpath("o:datestamp", "o" => OAI).text)
      item.collection_specs = header.xpath("o:setSpec", "o" => OAI).map(&:text)
      item.seen_at = seen_at
      item.deleted = header["status"] == "deleted"
      item.assign_attributes(metadata(record.at_xpath("o:metadata/d:dim", "o" => OAI, "d" => DIM))) unless item.deleted
      item.save!
    end

    def metadata(dim)
      fields = Hash.new { |hash, key| hash[key] = [] }
      dim&.xpath("d:field", "d" => DIM)&.each do |field|
        key = [ field["mdschema"], field["element"], field["qualifier"] ].compact.join(".")
        value = field.text.strip
        fields[key] << value if value.present?
      end

      issued = first(fields, "dc.date.issued", "dc.date.created")
      {
        title: first(fields, "dc.title"),
        item_type: first(fields, "dc.type"),
        issued: issued,
        issued_year: issued.to_s[/\A(1[89]|20)\d\d/]&.to_i,
        language: first(fields, "dc.language.iso", "dc.language"),
        abstract: first(fields, "dc.description.abstract"),
        doi: fields.values_at("dc.identifier.doi", "dc.identifier.other", "dc.identifier", "dc.identifier.citation").flatten.join(" ")[DOI, 1]&.sub(/[.,;)]+\z/, ""),
        author_names: fields.select { |key, _| key.start_with?("dc.contributor", "dc.creator") }.values.flatten,
        subjects: fields["dc.subject"],
        emails: fields["dc.data.correo"].flat_map { |value| value.scan(EMAIL) }.map(&:downcase).uniq
      }
    end

    def first(fields, *keys)
      keys.lazy.map { |key| fields[key].first }.find(&:present?)
    end
  end
end
