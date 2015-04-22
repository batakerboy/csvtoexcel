require 'csv'
require 'pathname'

# include GeneratParse::Base

class Report < ActiveRecord::Base

	def report_dir
		Rails.root.join("public", "uploads")
	end

	def start_parse(fileName = "biometrics.csv")
		# Sets filepath and searches for files with names starting with biometric_????? and saves the first in filePath na variable
		temp_filepath ||= File.join(self.report_dir, fileName)
		filePath = Dir.glob("#{temp_filepath}").first

		if File.exists?(filePath)
			puts "Start parsing"
		else 
			puts "No file found in #{filePath}"
			return
		end

		csvFile = CSV.open(filePath, 'r:ISO-8859-1')
		puts "=============="
		puts csvFile
		puts "=============="


		csvFile.each_with_index do |row, i|
		 	# if row[63].nil?
		 	# 	puts "Row no. #{i}: employee active"
		 	# else
		 	# 	puts "Row no. #{i}: employee inactive"
		 	# end
		 	token = row.to_s.split(/,(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)/).flatten.compact
		 	
		 	check_token62 = token[62].squeeze(" ").strip
		 	check_token53 = token[53].squeeze(" ").strip
		 	check_token33 = token[33].squeeze(" ").strip

		 	if check_token62 != 'nil]'
		 		#puts "Displaying value for #{i}: #{token[52]}"
		 		#puts "Employee #{i+1} is inactive"
		 		next
		 	elsif check_token53 != 'nil'
		 		name = token[5].split('(').first
		 		name = name[12..name.length-3]
				puts "\n #{name} is active"
				#puts "Date: #{token[25][2..token[25].length-2]} \n\t Time-in: #{token[26][2..token[26].length-2]} Time-out: #{token[27][2..token[27].length-2]}"
				puts "Date: #{token[25].tr('" ', '')} \n\t Time-in: #{token[26].tr('"', '')} Time-out: #{token[27].tr('"', '')}"
			elsif check_token33 != 'nil'
				puts "Date: #{token[5].tr('" ', '')} \n\t Time-in: #{token[6].tr('"', '')} Time-out: #{token[7].tr('"', '')}"		 	end
		 	#puts "#{token.length}"
		 
		end


		# string = 'Mustard Seed,1001 Summit One Office Tower 530 Shaw Blvd. Mandaluyong City,Telephone: 535-7333; Website: mseedsystems.com; Email: sales@mseedsystems.com,TIMESHEET REPORT,"From March 21, 2015 to April 03, 2015",03/24/15,11:02 AM, 2:07 pm,,,,,,,,,,,8,1,8,0,5.92,TOTAL EMPLOYEES:,22,Total Working Days:,14,Total Holidays W/in the Period:,0,Total Hours Required:,96,Mustard Seed Systems Bio-office Time and Attendance,Page -1 of 1,"Report Date: April 06, 2015",,,,,,,,,,,,,,,,,,,,,,,,,,,,,'.to_s

		# token = string.split(/,(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)/)
		# i = 1


		# puts token.size

		# # puts token[63].nil?
		# # puts "**"

		# # if token[63] == ' '
		# #     puts "Employee is active"
		# # else
		# #     puts "Employee is inactive"
		# # end

		# token.each do |t|
		# #  if t == ''
		# #     next
		# #  else
		#     puts "Column #{i}: #{t}"
		# #  end
		#  i += 1
		# end

	end

end
