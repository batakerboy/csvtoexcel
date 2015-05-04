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
		# File.delete(Rails.root + 'reports.zip')
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
		@@hours_late = 0
		@@times_late = 0
		@@hours_ot = 0
		@@times_vl = 0
		@@times_sl = 0
		CSV.generate do |csv|
			csv << ["iRipple, Inc."]
			csv << ["Name: #{emp.last_name}, #{emp.first_name}"]
			csv << ["Department: #{emp.department}"]
			csv << ["DATE", "DAY", "TIME IN", "TIME OUT", "UT DEPARTURE", "NO OF HRS LATE", "NO OF OT HOURS", "VL", "SL", "REMARKS"]
			requests.each do |req|
				@attendance = Attendance.where(employee_id: emp.id, attendance_date: req.date).first
				if !@attendance.nil? && !@attendance.time_in.nil? && (@attendance.time_in.strftime('%H:%M:%S').to_time > '08:30:00'.to_time)
					@@hours_late = @@hours_late + ((@attendance.time_in.strftime('%H:%M:%S').to_time - '08:30:00'.to_time)/1.hour)
					@@times_late = @@times_late + 1
				end
				if !@req.nil?
					@@hours_ot = @@hours_ot + req.ot_hours
					@@times_vl = @@times_vl + req.vacation_leave
					@@times_sl = @@times_sl + req.sick_leave
				end
				    csv << [req.date.strftime('%m-%d-%Y'),
				    	req.date.strftime('%A'), 
				    	(@attendance.time_in.to_time.strftime('%H:%M %P') if !@attendance.nil? && !@attendance.time_in.nil?), 
				    	(@attendance.time_out.to_time.strftime('%H:%M %P') if !@attendance.nil? && !@attendance.time_out.nil?), 
				    	req.ut_time,
				    	(((@attendance.time_in.strftime('%H:%M:%S').to_time - '08:30:00'.to_time)/1.hour).round(2) if !@attendance.nil? && !@attendance.time_in.nil? && @attendance.time_in.strftime('%H:%M:%S').to_time > '08:30:00'.to_time),
				    	req.ot_hours,
				    	req.vacation_leave,
				    	req.sick_leave,
				    	req.remarks]
	        end
	        csv << ["NUMBER OF TIMES TARDY", " ", " ", " ", " ", @@times_late]
	        csv << ["TOTAL TARDINESS", " ",  " ", " ", " ", @@hours_late.round(2)]
	        csv << ["TOTAL OT HOURS", " ", " ", " ", " ", " ", @@hours_ot]
	        csv << ["TOTAL LEAVES ACCUMULATED", " ", " ", " ", " ", " ", " ", @@times_vl, @@times_sl]
		end 
	end

  	def import 
  		Attendance.import(params[:biometrics], params[:falco])
  		Request.import(params[:file])
   		redirect_to reports_path, notice: 'Files Imported!' 
	end
end
