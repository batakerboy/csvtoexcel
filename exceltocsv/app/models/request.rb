require 'csv'

class Request < ActiveRecord::Base
	belongs_to :employee

	def self.import(file)
		employee_id = 0
		if file.to_s.split('/').last == "iEMS.csv"
			iEMS = File.open(file, 'r:ISO-8859-1')
			iEMS.each_with_index do |row, i|
				next if i == 0
				
				token = row.to_s.split(/,(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)/).flatten.compact
				
				next if token[4].length == 0 && token[5].length < 6

				# puts "Biometrics: #{token[4].length}"
				# puts "Falco: #{token[5].length}"
				
				unless employee_id == token[0]
					unless token[4].length == 0
						@employee = Employee.where(biometrics_id: token[4]).first
						unless @employee.nil?
							@employee.destroy if @employee.id != token[0]
						end
					end
					
					unless token[5].length < 6
						@employee = Employee.where(falco_id: token[5]).first
						unless @employee.nil?
							@employee.destroy if @employee.id != token[0]
						end
					end
					
					employee_id = token[0]

					@employee = Employee.where(id: employee_id).first
					unless @employee.nil?
						Employee.where(id: employee_id).update_all(last_name: token[1], first_name: token[2], department: token[3], biometrics_id: token[4], falco_id: token[5])
					else
						@employee = Employee.new(id: employee_id, last_name: token[1], first_name: token[2], department: token[3], biometrics_id: token[4], falco_id: token[5])
						# @employee = Employee.new
						# @employee.id = employee_id
						# @employee.last_name = token[1]
						# @employee.first_name = token[2]
						# @employee.department = token[3]
						# @employee.biometrics_id = token[4]
						# @employee.falco_id = token[5]
						@employee.save
					end
				end

				@request = Request.new
				@request.employee_id = employee_id
				@request.date = token[6]

				@request.regular_ot = token[7] unless token[7] == '0'
				@request.rest_or_special_ot = token[8] unless token[8] == '0'
				@request.special_on_rest_ot = token[9] unless token[9] == '0'
				@request.regular_holiday_ot = token[10] unless token[10] == '0'
				@request.regular_on_rest_ot = token[11] unless token[11] == '0'
				
				@request.ut_time = token[12] unless token[12] == '0'
				
				@request.vacation_leave = token[13] unless token[13] == '0'
				@request.vacation_leave_balance = token[14]

				@request.sick_leave = token[15] unless token[15] == '0'
				@request.sick_leave_balance = token[16]

				@request.ob_departure = token[17] unless token[17] == '0'
				@request.ob_time_start = token[18] unless token[18] == '0'
				@request.ob_time_end = token[19] unless token[19] == '0'
				@request.ob_arrival = token[20] unless token[20] == '0'
				
				@request.remarks = token[21]
				
				@request.save
			end
		end
	end
end
