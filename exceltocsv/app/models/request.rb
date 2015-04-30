require 'csv'

class Request < ActiveRecord::Base
	belongs_to :employee

	def self.import(file=nil)
		if !file.nil?
			spreadsheet = File.open(file.path, 'r:ISO-8859-1')
			spreadsheet.each_with_index do |row, i|
				next if i == 0
				token = row.to_s.split(/,(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)/).flatten.compact
				next if token.length < 2
				@request = Request.new
				@request.employee_id = token[0]
				# @request.last_name = token[0]
				# @request.first_name = token[1]
				@request.department = token[3]
				@request.date = token[4]
				# @request.remarks = "#{token[4]} Holiday" if token[4] == 'Regular' || token[4] == 'Special'
				@request.ot_hours = token[5] unless token[5] == '0'
				@request.ut_time = token[6] unless token[6] == '0'
				@request.vacation_leave = token[7] unless token[7] == '0'
				@request.sick_leave = token[8] unless token[8] == '0'
				@request.official_business = token[9] unless token[9] == '0'
				@request.remarks = token[10]
				# if !@request.remarks.nil? && !remarks.nil?
				# 	@request.remarks = "#{@request.remarks}, #{remarks}"
				# else
				# 	@request.remarks = token[10]
				# end
				@request.save
			end
		end
	end
end
