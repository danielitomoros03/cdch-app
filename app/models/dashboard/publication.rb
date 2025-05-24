# == Schema Information
#
# Table name: publications
#
#  id         :bigint           not null, primary key
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
module Dashboard
    class Publication < ApplicationRecord
    end
end
