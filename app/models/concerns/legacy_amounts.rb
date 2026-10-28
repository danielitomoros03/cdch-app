# Montos del sistema heredado. Cada registro trae la moneda de su época, y los que
# la captura dejó dudosos (aprobado más de 10 veces lo solicitado) se marcan con
# amount_flagged para no usarlos en totales.
module LegacyAmounts
  extend ActiveSupport::Concern

  CURRENCIES = %w[VEB VEF VES VED].freeze

  included do
    validates :currency, inclusion: { in: CURRENCIES }, allow_nil: true
    scope :reliable_amounts, -> { where(amount_flagged: false) }
  end
end
