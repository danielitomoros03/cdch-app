# Publicación de Saber-UCV (repositorio DSpace), cosechada por OAI-PMH con Saber::Harvester.
# Es una copia de solo lectura: Saber es la fuente.
# == Schema Information
#
# Table name: saber_items
#
#  id               :bigint           not null, primary key
#  abstract         :text
#  author_names     :jsonb            not null
#  collection_specs :jsonb            not null
#  datestamp        :datetime
#  deleted          :boolean          default(FALSE), not null
#  doi              :string
#  emails           :jsonb            not null
#  handle           :string           not null
#  issued           :string
#  issued_year      :integer
#  item_type        :string
#  kind             :string           default("otro"), not null
#  language         :string
#  seen_at          :datetime
#  subjects         :jsonb            not null
#  title            :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_saber_items_on_datestamp  (datestamp)
#  index_saber_items_on_handle     (handle) UNIQUE
#  index_saber_items_on_kind       (kind)
#
class SaberItem < ApplicationRecord
  HANDLE_BASE = "https://saber.ucv.ve/jspui/handle/".freeze

  # Tipos de Saber en castellano. Saber escribe el tipo a mano (en inglés o en castellano,
  # con variantes): se agrupan por patrón; lo que no encaja queda como "otro".
  KINDS = {
    "articulo" => [ "Artículo", /\Aartic|\Aarticle/ ],
    "libro" => [ "Libro", /\Abook\z/ ],
    "capitulo" => [ "Capítulo de libro", /chapter|capitulo/ ],
    "tesis_doctoral" => [ "Tesis doctoral", /doctoral/ ],
    "tesis_maestria" => [ "Tesis de maestría", /master|maestria/ ],
    "trabajo_grado" => [ "Trabajo de grado", /bachelor|trabajo de grado/ ],
    "tesis" => [ "Tesis", /thesis|tesis/ ],
    "presentacion" => [ "Presentación", /presenta/ ],
    "informe_tecnico" => [ "Informe técnico", /report|informe/ ],
    "documento_trabajo" => [ "Documento de trabajo", /working paper/ ],
    "preprint" => [ "Preprint", /preprint/ ],
    "curriculo" => [ "Currículo", /curriculum/ ],
    "mapa" => [ "Mapa o plano", /\Amap\z|blueprint/ ],
    "imagen" => [ "Imagen", /image/ ],
    "video" => [ "Video o animación", /video|animation/ ],
    "grabacion" => [ "Grabación", /recording/ ],
    "datos" => [ "Conjunto de datos", /dataset/ ],
    "objeto_aprendizaje" => [ "Objeto de aprendizaje", /learning object/ ],
    "otro" => [ "Otro", nil ]
  }.freeze

  def self.kind_for(item_type)
    text = I18n.transliterate(item_type.to_s).downcase.strip
    KINDS.find { |_key, (_label, pattern)| pattern&.match?(text) }&.first || "otro"
  end

  def self.kind_label(kind)
    KINDS.dig(kind, 0) || KINDS["otro"][0]
  end

  has_many :authorships, class_name: "SaberAuthorship", dependent: :delete_all

  scope :current, -> { where(deleted: false) }

  validates :handle, presence: true, uniqueness: true

  before_save { self.kind = self.class.kind_for(item_type) if item_type_changed? || new_record? }

  def kind_label
    self.class.kind_label(kind)
  end

  def url
    "#{HANDLE_BASE}#{handle}"
  end

  def doi_url
    "https://doi.org/#{doi}" if doi.present?
  end
end
