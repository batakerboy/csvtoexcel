require 'csv'
require 'pathname'

class Attendance < ActiveRecord::Base
	belongs_to :employee

	@@biometrics_id = ' '
	
	def self.date_biometrics(date)
		token = date.tr('"" ', '').split("/")
		formatted_date = "20#{token[2]}-#{token[0]}-#{token[1]}"
		return formatted_date
	end

	def self.date_falco(date)
		token = date.tr('"" ', '').split("/")
		formatted_date = "#{token[0]}-#{token[1]}-#{token[2]}"
		return formatted_date
	end

	def self.import(file)
		if file.to_s.split('/').last == "biometrics.csv"
			csvFile = CSV.open(file, 'r:ISO-8859-1')
			csvFile.each_with_index do |row|
				token = row.to_s.split(/,(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)/).flatten.compact
			 	
			 	check_token62 = token[62].squeeze(" ").strip
			 	check_token53 = token[53].squeeze(" ").strip
			 	check_token33 = token[33].squeeze(" ").strip

			 	if check_token62 != 'nil]'
			 		next
			 	elsif check_token53 != 'nil'
			 		@@biometrics_id = token[5].downcase.tr('":, abcdefghijklmnopqrstuvwxyz()', '')
			 		@employee = Employee.where(biometrics_id: @@biometrics_id).first
			 		
			 		next if @employee.nil?

			 		@attendance = Attendance.where(employee_id: @employee.id, attendance_date: date_biometrics(token[25].tr('" ', ''))).first
			 		
		 			puts "======================="
					puts "BIOMETRICS"
					puts "Date: #{@attendance.time_out}"
					puts "token: #{token[27]}"
					puts "token.length: #{token[27].length}"
					puts "token: #{token[27].tr('"', '').to_time}"
					puts "======================="

			 		unless @attendance.nil?
			 			Attendance.update(@attendance.id, time_in: token[26].tr('"', '').to_time) if @attendance.time_in.strftime('%H:%M:%S').to_time > token[26].tr('"', '').to_time
						if !token[27].nil? && token[27] != 'nil' && token[27].length != 4
							if @attendance.time_out.nil?
								Attendance.update(@attendance.id, time_out: token[27].tr('"', '').to_time)
							elsif @attendance.time_out.strftime('%H:%M:%S').to_time < token[27].tr('"', '').to_time
								Attendance.update(@attendance.id, time_out: token[27].tr('"', '').to_time)
							end 
						end
			 		else
				 		@attendance = Attendance.new
				 		@attendance.employee_id = @employee.id
				 		@attendance.attendance_date = date_biometrics(token[25]).to_date
				 		@attendance.time_in = token[26].tr('"', '').to_time
			 			

			 			timeout = token[27].tr('"', '')
				 		if timeout.length == 3
				 			@attendance.time_out = ' '
				 		else 
				 			@attendance.time_out = timeout.to_time
				 		end
			 			@attendance.save
			 		end
			 		
				elsif check_token33 != 'nil'
					next if @employee.nil?

					@attendance = Attendance.where(employee_id: @employee.id, attendance_date: date_biometrics(token[5])).first
					
					unless @attendance.nil?
						Attendance.update(@attendance.id, time_in: token[6].tr('"', '').to_time) if @attendance.time_in.strftime('%H:%M:%S').to_time > token[6].tr('"', '').to_time
						if @attendance.time_out.nil?
							Attendance.update(@attendance.id, time_out: token[7].tr('" ', '').to_time)
						elsif !!token[7].tr('" ', '').nil? && (@attendance.time_out.strftime('%H:%M:%S').to_time < token[7].tr('" ', '').to_time)
							Attendance.update(@attendance.id, time_out: token[7].tr('" ', '').to_time)
						end 
					else
						@attendance = Attendance.new
						@attendance.employee_id = @employee.id if !@employee.nil?
				 		

				 		@attendance.attendance_date = date_biometrics(token[5]).to_date
				 		@attendance.time_in = token[6].tr('"', '').to_time

						puts "======================="
						puts "BIOMETRICS"
						puts "@attendance_date: #{@attendance.attendance_date}"
						puts "Date: #{date_biometrics(token[5])}"
						puts "token: #{token[5]}"
						puts "======================="
				 		
				 		timeout = token[7].tr('"', '')
				 		if timeout.nil?
				 			@attendance.time_out = ' '
				 		else 
				 			@attendance.time_out = timeout.to_time
				 		end
				 		@attendance.save
					end
				end
			end
		end

		if file.to_s.split('/').last == "falco.txt"
			textFile = File.open(file, 'r:ISO-8859-1')
			textFile.each_with_index do |row|
				token = row.gsub(/\s+/m, ' ').split(" ")
				unless token.length == 0 || token[2] == 'FFFFFF' || token[2] == 'Access' || token[2] == 'Report' || token[2].nil?
					unless token[2].length != 6
						falco_id = token[2].tr('" ', '')
						date = date_falco(token[0])
						
						@employee = Employee.where(falco_id: falco_id).first 
						next if @employee.nil?
						@attendance = Attendance.where(employee_id: @employee.id, attendance_date: date).first
						
						if @attendance.nil?
							@attendance = Attendance.new
							@attendance.employee_id = @employee.id
							@attendance.attendance_date = date
							@attendance.time_in = token[1].to_time
							@attendance.save
						else
							Attendance.update(@attendance.id, time_in: token[1].to_time) if @attendance.time_in.strftime('%H:%M:%S') > token[1].to_time.strftime('%H:%M:%S')
							if @attendance.time_out.nil?
								Attendance.update(@attendance.id, time_out: token[1].to_time)
							elsif @attendance.time_out.strftime('%H:%M:%S') < token[1].to_time.strftime('%H:%M:%S')
								Attendance.update(@attendance.id, time_out: token[1].to_time)
							end 
						end
					end
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



# csvFile = CSV.open(falco.path, 'r:ISO-8859-1')
			# csvFile.each_with_index do |row, i|
			# 	next if i == 0
			# 	next if i == 1
			# 	token = row.to_s.split(/,(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)/).flatten.compact
			# 	name =  token[3].tr('"', '')[1..token[3].length-1]
			# 	last_name = name.split(", ").first
			# 	first_name = name.split(", ").last
			# 	date = date_falco(token[0].tr('"[ ', ''))
			# 	newtime_in = token[5].tr('" ', '')
			# 	newtime_out = token[6].tr('"] ', '')e
			# 	@attendance = Attendance.find_by_sql("SELECT * FROM attendances WHERE attendance_date = '#{date}' AND last_name = '#{last_name}' AND first_name = '#{first_name}'")
			# 	if @attendance[0].nil?
			# 		@attendance = Attendance.new
			# 		@attendance.attendance_date = date
			# 		@attendance.last_name = last_name
			# 		@attendance.first_name = first_name
			# 		@attendance.time_in = newtime_in.to_time
			# 		if newtime_out.length == 3
			# 			@attendance.time_out = ' '
			# 		else @attendance.time_out = newtime_out.to_time
			# 		end
			# 		@attendance.save

			# 		puts "========================================================="
			# 		puts "FALCO"
			# 		puts "========================================================="
			# 		puts "Time in: String = #{newtime_in} \t Time = #{newtime_in.to_time}"
			# 		puts "========================================================="
			# 		puts "Time out: String = #{newtime_out} \t Time = #{newtime_out.to_time}"
			# 		puts "========================================================="
			# 		puts "#{@attendance.last_name}, #{@attendance.first_name}: Time in: #{@attendance.time_in} \t Time out: #{@attendance.time_out}"
			# 		puts "========================================================="
			# 	else	
			# 		Attendance.update(@attendance[0].id, time_in: newtime_in.to_time) if @attendance[0].time_in.strftime('%H:%M:%S') > newtime_in.to_time.strftime('%H:%M:%S')
			# 		if newtime_out != 'nil'
			# 			if @attendance[0].time_out.nil?
			# 				Attendance.update(@attendance[0].id, time_out: newtime_out.to_time)
			# 			elsif @attendance[0].time_out.strftime('%H:%M:%S') < newtime_out.to_time.strftime('%H:%M:%S')
			# 				Attendance.update(@attendance[0].id, time_out: newtime_out.to_time)
			# 			end
			# 		end	
			# 		puts "========================================================="
			# 		puts "FALCO"
			# 		puts "========================================================="
			# 		puts "Time in: String = #{newtime_in} \t Time = #{newtime_in.to_time}"
			# 		puts "========================================================="
			# 		puts "Time out: String = #{newtime_out} \t Time = #{newtime_out.to_time}"
			# 		puts "========================================================="
			# 		puts "#{@attendance[0].last_name}, #{@attendance[0].first_name}: Time in: #{@attendance[0].time_in.to_time} \t Time out: #{@attendance[0].time_out.to_time if !@attendance[0].time_out.nil?}"
			# 		puts "========================================================="
			# 	end
			# end