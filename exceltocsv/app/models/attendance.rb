class Attendance < ActiveRecord::Base
	def self.to_csv()
		CSV.generate do |csv|
			@cols = ["Name", "Date", "Time In", "Time Out"] 
		    Attendance.all.each do |attendance|
			    csv << [attendance.name, attendance.attendance_date.to_datetime.strftime('%m/%d/%Y'), attendance.time_in.strftime('%H:%M:%S'), attendance.time_out.strftime('%H:%M:%S')] 
		    end
		end
	end
end
