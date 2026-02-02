# == Schema Information
#
# Table name: calls
#
#  id                :bigint           not null, primary key
#  active            :boolean          default(FALSE)
#  end_date          :datetime
#  kind              :integer
#  short_description :string
#  start_date        :datetime
#  title             :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
class Call < ApplicationRecord
    ## Enum for kind
    # This enum defines the kind of call
    enum kind: [ :Call, :Holidays, :News ]

    has_rich_text :large_description

    ## Method to desactivate calls
    def desactive
        if self.end_date < Date.today
            self.active = false
            self.save
        end
    end

    def timeLeft
        if self.end_date > Date.today
            return (self.end_date.to_date - Date.today).to_i
        else
            return 0
        end
    end
end
