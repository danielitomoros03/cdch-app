# == Schema Information
#
# Table name: institutions
#
#  id              :bigint           not null, primary key
#  acronym         :string
#  address         :string
#  business_hours  :string
#  description     :text
#  director_email  :string
#  director_name   :string
#  facebook_url    :string
#  founded_year    :integer
#  instagram_url   :string
#  linkedin_url    :string
#  mission         :text
#  name            :string
#  primary_email   :string
#  primary_phone   :string
#  secondary_email :string
#  secondary_phone :string
#  threads_url     :string
#  twitter_url     :string
#  vission         :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class Institution < ApplicationRecord
    # Attachment for Institution's Logo
    has_one_attached :logoInstitution

    # CDCH's History with Rich Text
    has_rich_text :history

    # Validations
    validates :name, presence: true
    validates :address, presence: true
    validates :primary_phone, presence: true
    validates :primary_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :secondary_email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
    validates :director_email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
    validates :mission, presence: true
    validates :vission, presence: true
    validates :description, presence: true
    validates :founded_year, numericality: { only_integer: true, greater_than: 1800, less_than_or_equal_to: Time.current.year }, allow_nil: true

    # Validate URLs
    validates :twitter_url, :facebook_url, :instagram_url, :linkedin_url, :threads_url,
              format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "debe ser una URL válida" },
              allow_blank: true
end
