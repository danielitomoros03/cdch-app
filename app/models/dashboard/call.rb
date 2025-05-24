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
module Dashboard
    class Call < ApplicationRecord
    end
end
