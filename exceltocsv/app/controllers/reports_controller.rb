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
		    Employee.find_by_sql("SELECT * FROM employees ORDER BY id").each do |emp|
		    	@requests = Request.find_by_sql("SELECT * FROM requests WHERE employee_id == '#{emp.id}'")
				zipfile.get_output_stream("#{emp.last_name}_#{emp.first_name}.xls") { |f| 
					f.puts(to_csv(@requests, emp))
				}
			end
		}
	end

	def to_csv(requests, emp)
		CSV.generate do |csv|
			csv << ["iRipple, Inc."]
			csv << ["Name: #{emp.last_name}, #{emp.first_name}"]
			csv << ["Department: #{emp.department}"]
			csv << ["DATE", "DAY", "TIME IN", "TIME OUT", "NO OF HRS LATE", "NO OF OT HOURS", "VL", "SL", "REMARKS"]
			requests.each do |req|     
				@attendance = Attendance.where(employee_id: emp.id, attendance_date: req.date).first
				    csv << [req.date.strftime('%m-%d-%Y'), 
				    	req.date.strftime('%A'), 
				    	(@attendance.time_in.to_time.strftime('%H:%M %P') if !@attendance.nil? && !@attendance.time_in.nil?), 
				    	(@attendance.time_out.to_time.strftime('%H:%M %P') if !@attendance.nil? && !@attendance.time_out.nil?), 
				    	(((@attendance.time_in.strftime('%H:%M:%S').to_time - '08:30:00'.to_time)/1.hour).round(2)  if !@attendance.nil? && !@attendance.time_in.nil? && @attendance.time_in.strftime('%H:%M:%S').to_time > '08:30:00'.to_time),
				    	req.ut_time,
				    	req.ot_hours,
				    	req.vacation_leave,
				    	req.sick_leave,
				    	req.remarks]
	        end 
		end 
	end

	# def create_zip
	# 	Zip::File.open('reports.zip', Zip::File::CREATE) { |zipfile|
	# 	    Attendance.find_by_sql("SELECT DISTINCT last_name, first_name FROM attendances ORDER BY last_name").each do |name|
	# 	    	@attendances = Attendance.find_by_sql("SELECT * FROM attendances WHERE last_name == '#{name.last_name}' AND first_name == '#{name.first_name}'")
	# 			zipfile.get_output_stream("#{name.last_name}_#{name.first_name}.xls") { |f| 
	# 				f.puts(to_csv(@attendances))
	# 			}
	# 		end
	# 	}
	# end

	# def to_csv(attendances)
	# 	CSV.generate do |csv|
	# 		csv << ["Name", "Date", "Time-in", "Time-out"]
	# 	    attendances.each do |attendance|
	# 		    csv << ["#{attendance.last_name}, #{attendance.first_name}", attendance.attendance_date.to_date.strftime('%m/%d/%Y'), attendance.time_in.to_time.strftime('%H:%M:%S'), (attendance.time_out.to_time.strftime('%H:%M:%S') if !attendance.time_out.nil?)] 
	# 	    end
	# 	end
	# end

  	def import 
  		Attendance.import(params[:biometrics], params[:falco])
  		Request.import(params[:file])
   		redirect_to reports_path, notice: 'Files Imported!' 
	end
end