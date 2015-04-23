require 'csv'
require 'pathname'

# include GeneratParse::Base

class Report < ActiveRecord::Base

	# def new_records_falco
	# 	csvFile = CSV.open(falco.path, 'r:ISO-8859-1')
	# 	csvFile.each_with_index do |row, i|
	# 		next if i == 0
	# 		next if i == 1
	# 		token = row.to_s.split(/,(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)/).flatten.compact
	# 		@attendance = Attendance.new
	# 		@attendance.attendance_date = date_falco(token[0].tr('"[ ', ''))
	# 		@attendance.name = token[3].tr('"', '')
	# 		@attendance.time_in = token[5].tr('" ', '').to_time.strftime('%H:%M:%S')
	# 		if token[6].squeeze(" ").strip != 'nil'
	# 			@attendance.time_out = token[6].tr('" ', '').to_time.strftime('%H:%M:%S')
	# 		else @attendance.time_out = ' '
	# 		end
	# 		@attendance.save
	# 	end
	# end

	# def self.update_records_falco(falco)
		
	# end

	# def start_parse(fileName = "biometrics.csv")
	# 	# Sets filepath and searches for files with names starting with biometric_????? and saves the first in filePath na variable
	# 	temp_filepath ||= File.join(self.report_dir, fileName)
	# 	filePath = Dir.glob("#{temp_filepath}").first

	# 	if File.exists?(filePath)
	# 		puts "Start parsing"
	# 	else 
	# 		puts "No file found in #{filePath}"
	# 		return
	# 	end

	# 	csvFile = CSV.open(filePath, 'r:ISO-8859-1')
	# 	puts "=============="
	# 	puts csvFile
	# 	puts "=============="


	# 	csvFile.each_with_index do |row, i|

	# 	 	token = row.to_s.split(/,(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)/).flatten.compact
		 	
	# 	 	check_token62 = token[62].squeeze(" ").strip
	# 	 	check_token53 = token[53].squeeze(" ").strip
	# 	 	check_token33 = token[33].squeeze(" ").strip

	# 	 	if check_token62 != 'nil]'
	# 	 		next
	# 	 	elsif check_token53 != 'nil'
	# 	 		name = token[5].split('(').first
	# 	 		name = name[12..name.length-3]
	# 			puts "\n #{name} is active"
	# 			puts "Date: #{token[25].tr('" ', '')} \n\t Time-in: #{token[26].tr('"', '')} Time-out: #{token[27].tr('"', '')}"
	# 		elsif check_token33 != 'nil'
	# 			puts "Date: #{token[5].tr('" ', '')} \n\t Time-in: #{token[6].tr('"', '')} Time-out: #{token[7].tr('"', '')}"		 	
	# 		end
	# 	end
	# end
end