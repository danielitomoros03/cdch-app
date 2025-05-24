# == Schema Information
#
# Table name: directories
#
#  id         :bigint           not null, primary key
#  day        :date
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
module Dashboard
    class Directory < ApplicationRecord
    end
end
