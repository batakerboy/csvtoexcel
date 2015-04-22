module Parse::Base
	include FileUtils
	
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

		csvFile = CSV.open(filePath)
		puts csvFile

		
	end

end