module EventsHelper
	def event_date_label(day)
		day.present? ? l(day, format: "%d/%m/%Y") : "-"
	end

	def event_time_label(time)
		time.present? ? time.strftime("%H:%M") : "-"
	end
end
