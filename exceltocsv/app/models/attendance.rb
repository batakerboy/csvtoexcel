require 'csv'
require 'pathname'

class Attendance < ActiveRecord::Base
	@@name = ' '
	
	def self.date_biometrics(date)
		token = date.split("/")
		formatted_date = "20" + token[2] + '-' + token[0] + '-' + token[1]
		return formatted_date
	end

	def self.date_falco(date)
		token = date.split("/")
		formatted_date = token[0] + '-' + token[1] + '-' + token[2]
		return formatted_date
	end

	def self.import(biometrics = nil, falco = nil)
		if !biometrics.nil?
			csvFile = CSV.open(biometrics.path, 'r:ISO-8859-1')
			csvFile.each_with_index do |row|
				token = row.to_s.split(/,(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)/).flatten.compact
			 	
			 	check_token62 = token[62].squeeze(" ").strip
			 	check_token53 = token[53].squeeze(" ").strip
			 	check_token33 = token[33].squeeze(" ").strip

			 	if check_token62 != 'nil]'
			 		next
			 	elsif check_token53 != 'nil'
			 		@@name = token[5].split('(').first
			 		@@name = @@name[12..@@name.length-3]
			 		@attendance = Attendance.new
			 		@attendance.last_name = @@name.split(", ").first
			 		@attendance.first_name = @@name.split(", ").last
			 		newdate = date_biometrics(token[25].tr('" ', ''))
			 		timein = token[26].tr('"', '')
			 		if timein[0] == ' '
			 			timein = timein[1..timein.length]
			 		end
			 		timeout = token[27].tr('"', '')
			 		if timeout[0] == ' '
			 			timeout = timeout[1..timeout.length]
			 		end
			 		@attendance.attendance_date = newdate
			 		# @attendance.time_in = (newdate + " " + timein).to_datetime
			 		@attendance.time_in = timein.to_time
			 		if timeout.length == 3
			 			@attendance.time_out = ' '
			 		# else @attendance.time_out = (newdate + " " + timeout).to_datetime
			 		else @attendance.time_out = timeout.to_time
			 		end
			 		@attendance.save
				elsif check_token33 != 'nil'
					@attendance = Attendance.new
			 		@attendance.last_name = @@name.split(", ").first
			 		@attendance.first_name = @@name.split(", ").last
			 		newdate = date_biometrics(token[5].tr('" ', ''))
			 		timein = token[6].tr('" ', '')
			 		# if timein[0] == ' '
			 		# 	timein = timein[1..timein.length]
			 		# end
			 		timeout = token[7].tr('" ', '')
			 		# if timeout[0] == ' '
			 		# 	timeout = timeout[1..timeout.length]
			 		# end
			 		@attendance.attendance_date = newdate
			 		# @attendance.time_in = (newdate + " " + timein).to_datetime
			 		@attendance.time_in = timein.to_time
			 		if timeout.nil?
			 			@attendance.time_out = ' '
			 		# else @attendance.time_out = (newdate + " " + timeout).to_datetime
			 		else @attendance.time_out = timeout.to_time
			 		end
			 		@attendance.save
				end
				puts "========================================================="
				puts "BIOMETRICS"
				puts "========================================================="
				puts "Time in: String = #{timein} \t Time = #{timein.to_time}"
				puts "========================================================="
				puts "Time out: String = #{timeout} \t Time = #{timeout.to_time}"
				puts "========================================================="
				puts "#{@attendance.last_name}, #{@attendance.first_name}: Time in: #{@attendance.time_in} \t Time out: #{@attendance.time_out}"
				puts "========================================================="
			end
		end

		if !falco.nil?
			csvFile = CSV.open(falco.path, 'r:ISO-8859-1')
			csvFile.each_with_index do |row, i|
				next if i == 0
				next if i == 1
				token = row.to_s.split(/,(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)/).flatten.compact
				name =  token[3].tr('"', '')[1..token[3].length-1]
				last_name = name.split(", ").first
				first_name = name.split(", ").last
				date = date_falco(token[0].tr('"[ ', ''))
				newtime_in = token[5].tr('" ', '')
				newtime_out = token[6].tr('"] ', '')
				# newdatein = (date + " " + newtime_in).to_datetime
				# newdateout = (date + " " + newtime_out).to_datetime
				@attendance = Attendance.find_by_sql("SELECT * FROM attendances WHERE attendance_date = '#{date}' AND last_name = '#{last_name}' AND first_name = '#{first_name}'")
				if @attendance[0].nil?
					@attendance = Attendance.new
					@attendance.attendance_date = date
					@attendance.last_name = last_name
					@attendance.first_name = first_name
					# @attendance.time_in = newdatein
					@attendance.time_in = newtime_in.to_time
					if newtime_out.length == 3
						@attendance.time_out = ' '
					# else @attendance.time_out = newdateout
					else @attendance.time_out = newtime_out.to_time
					end
					@attendance.save

					puts "========================================================="
					puts "FALCO"
					puts "========================================================="
					puts "Time in: String = #{newtime_in} \t Time = #{newtime_in.to_time}"
					puts "========================================================="
					puts "Time out: String = #{newtime_out} \t Time = #{newtime_out.to_time}"
					puts "========================================================="
					puts "#{@attendance.last_name}, #{@attendance.first_name}: Time in: #{@attendance.time_in} \t Time out: #{@attendance.time_out}"
					puts "========================================================="
				else	
					Attendance.update(@attendance[0].id, time_in: newtime_in.to_time) if @attendance[0].time_in.strftime('%H:%M:%S') > newtime_in.to_time.strftime('%H:%M:%S')
					if newtime_out != 'nil'
						if @attendance[0].time_out.nil?
							Attendance.update(@attendance[0].id, time_out: newtime_out.to_time)
						elsif @attendance[0].time_out.strftime('%H:%M:%S') < newtime_out.to_time.strftime('%H:%M:%S')
							Attendance.update(@attendance[0].id, time_out: newtime_out.to_time)
						end
					end	
					puts "========================================================="
					puts "FALCO"
					puts "========================================================="
					puts "Time in: String = #{newtime_in} \t Time = #{newtime_in.to_time}"
					puts "========================================================="
					puts "Time out: String = #{newtime_out} \t Time = #{newtime_out.to_time}"
					puts "========================================================="
					puts "#{@attendance[0].last_name}, #{@attendance[0].first_name}: Time in: #{@attendance[0].time_in.to_time} \t Time out: #{@attendance[0].time_out.to_time if !@attendance[0].time_out.nil?}"
					puts "========================================================="
				end
			end
		end
	end

	def self.to_csv()
		CSV.generate do |csv|
			@cols = ["Name", "Date", "Time In", "Time Out"] 
		    Attendance.all.each do |attendance|
			    csv << [attendance.name, attendance.attendance_date.to_date.strftime('%m/%d/%Y'), attendance.time_in.to_time.strftime('%H:%M:%S'), (attendance.time_out.to_time.strftime('%H:%M:%S') if !attendance.time_out.nil?)] 
		    end
		end
	end
end
