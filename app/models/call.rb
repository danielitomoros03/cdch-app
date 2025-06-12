# == Schema Information
#
# Table name: calls
#
#  id                :bigint           not null, primary key
#  active            :boolean          default(FALSE)
#  end_date          :datetime
#  short_description :string
#  start_date        :datetime
#  title             :string           not null
#  type              :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
class Call < ApplicationRecord
    ## Enum for type
    # This enum defines the type of call, which can be a call, holidays, or news.
    enum type: [ :Call, :Holidays, :News ]
end
