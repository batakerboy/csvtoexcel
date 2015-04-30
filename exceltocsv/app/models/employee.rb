require 'csv'
require 'pathname'

class Employee < ActiveRecord::Base
	has_many :attendance
	has_many :request

	def self.import(file=nil)
		if !file.nil?
			csvFile = CSV.open(file.path, 'r:ISO-8859-1')
			csvFile.each_with_index do |row|
				token = row.to_s.split(/,(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)/).flatten.compact
				id = token[0].tr('[]" ', '')
				last_name = token[1].tr('[]"', '')
				first_name = token[2].tr('[]"', '')
				department = token[3].tr('[]"', '')
				biometrics_id = token[4].tr('[] "', '')
				falco_id = token[5].tr('[] "', '')
				@employee = Employee.where(id: id).first
				if !@employee.nil?
					Employee.where(id: id).update_all(last_name: last_name, first_name: first_name, department: department, biometrics_id: biometrics_id, falco_id: falco_id)
				else
					@employee = Employee.new
					@employee.id = id
					@employee.last_name = last_name
					@employee.first_name = first_name
					@employee.department = department
					@employee.biometrics_id = biometrics_id
					@employee.falco_id = falco_id
					@employee.save
				end
			end
		end
	end
end
