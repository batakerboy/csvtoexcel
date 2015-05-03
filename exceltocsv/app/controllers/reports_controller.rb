include FileUtils
require 'csv'
require 'pathname'
require 'rubygems'
require 'zip'
class ReportsController < ApplicationController

	def index
		@attendances = Attendance.all
		@requests = Request.all
		@date_start = '2015-03-21'.to_date
		@date_end = '2015-04-03'.to_date
		@date ||= @date_start 
		@employees = Employee.all
		# respond_to do |format|
		# 	format.html
		# 	format.xls { send_data @attendances.to_csv }
		# end
	end

	def download_zip
		zip = create_zip
	  	send_file(Rails.root.join('reports.zip'), type: 'application/zip', filename: 'reports.zip')
	end

	def create_zip
		Zip::File.open('reports.zip', Zip::File::CREATE) { |zipfile|
		    Attendance.find_by_sql("SELECT DISTINCT last_name, first_name FROM attendances ORDER BY last_name").each do |name|
		    	@attendances = Attendance.find_by_sql("SELECT * FROM attendances WHERE last_name == '#{name.last_name}' AND first_name == '#{name.first_name}'")
				zipfile.get_output_stream("#{name.last_name}_#{name.first_name}.xls") { |f| 
					f.puts(to_csv(@attendances))
				}
			end
		}

	end

	def to_csv(attendances)
		CSV.generate do |csv|
			csv << ["Name", "Date", "Time-in", "Time-out"]
		    attendances.each do |attendance|
			    csv << ["#{attendance.last_name}, #{attendance.first_name}", attendance.attendance_date.to_date.strftime('%m/%d/%Y'), attendance.time_in.to_time.strftime('%H:%M:%S'), (attendance.time_out.to_time.strftime('%H:%M:%S') if !attendance.time_out.nil?)] 
		    end
		end
	end

  	def import 
  		Attendance.import(params[:biometrics], params[:falco])
  		Request.import(params[:file])
   		redirect_to reports_path, notice: 'Files Imported!' 
	end
end