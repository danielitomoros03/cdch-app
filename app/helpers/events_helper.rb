module EventsHelper
	def event_date_label(day, fallback: "-")
		day.present? ? l(day, format: "%d/%m/%Y") : fallback
	end

	def event_time_label(time, fallback: "-")
		time.present? ? time.strftime("%H:%M") : fallback
	end
end
