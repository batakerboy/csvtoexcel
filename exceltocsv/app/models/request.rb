require 'csv'

class Request < ActiveRecord::Base
	belongs_to :employee

	def self.import(file)
		array_of_ids = Array.new
		employee_id = 0
		if file.to_s.split('/').last == "iEMS.csv"
			iEMS = File.open(file, 'r:ISO-8859-1')
			iEMS.each_with_index do |row, i|
				next if i == 0 || i == 1
				
				token = row.to_s.split(/,(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)/).flatten.compact
				
				next if token[5].length == 0 && token[6].length < 6

				unless employee_id == token[0]
					unless token[5].length == 0
						@employee = Employee.where(biometrics_id: token[5]).first
						unless @employee.nil?
							@employee.destroy if @employee.id != token[0]
						end
					end
					
					unless token[6].length < 6
						@employee = Employee.where(falco_id: token[6]).first
						unless @employee.nil?
							@employee.destroy if @employee.id != token[0]
						end
					end
					
					employee_id = token[0]

					array_of_ids.push(employee_id)

					@employee = Employee.where(id: employee_id).first
					unless @employee.nil?
						Employee.where(id: employee_id).update_all(last_name: token[1].tr('"', ''), first_name: token[2].tr('"', ''), is_manager: token[3], department: token[4], biometrics_id: token[5], falco_id: token[6])
					else
						@employee = Employee.new(id: employee_id, last_name: token[1].tr('"', ''), first_name: token[2].tr('"', ''), is_manager: token[3], department: token[4], biometrics_id: token[5], falco_id: token[6])
						@employee.save
					end
				end

				@request = Request.where(employee_id: employee_id, date: token[7]).first

				unless @request.nil?
					Request.where(employee_id: employee_id, date: token[7]).update_all(employee_id: employee_id, date: token[7], regular_ot: token[8], rest_or_special_ot: token[9], special_on_rest_ot: token[10], regular_holiday_ot: token[11], regular_on_rest_ot: token[12], ut_time: token[13], vacation_leave: token[14], vacation_leave_balance: token[15], sick_leave: token[16], sick_leave_balance: token[17], ob_departure: (token[18] unless token[18].nil? || token[18] == ''), ob_time_start: (token[19] unless token[19].nil? || token[19] == ''), ob_time_end: (token[20] unless token[20].nil? || token[20] == ''), ob_arrival: (token[21] unless token[21].nil? || token[21] == ''), offset: token[22], is_holiday: token[23], remarks: token[24])
				else
					@request = Request.new(employee_id: employee_id, date: token[7], regular_ot: token[8], rest_or_special_ot: token[9], special_on_rest_ot: token[10], regular_holiday_ot: token[11], regular_on_rest_ot: token[12], ut_time: token[13], vacation_leave: token[14], vacation_leave_balance: token[15], sick_leave: token[16], sick_leave_balance: token[17], ob_departure: token[18], ob_time_start: token[19], ob_time_end: token[20], ob_arrival: token[21], offset: token[22], is_holiday: token[23], remarks: token[24])
					@request.save
				end
			end
		end

		return array_of_ids
	end
end
