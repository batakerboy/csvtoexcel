include FileUtils
require 'csv'
require 'pathname'
require 'rubygems'
require 'zip'
class ReportsController < ApplicationController

	def index
		# @attendances = Attendance.all
		# @requests = Request.all
		# @date_start = '2015-03-21'.to_date
		# @date_end = '2015-04-03'.to_date
		# @date ||= @date_start 
		# @employees = Employee.all
		# respond_to do |format|
		# 	format.html
		# 	format.xls { send_data @attendances.to_csv }
		# end
	end

	def download_zip
	  	File.delete(Rails.root + 'reports.zip') if File.exists?(Rails.root + 'reports.zip')
	  	@date_start = params[:date_start]
	  	@date_end = params[:date_end]
	  	# puts "==============================================="
	  	# puts "#{@date_start}"
	  	# puts "#{@date_end}"
	  	# puts "==============================================="
		zip = create_zip
	  	send_file(Rails.root.join('reports.zip'), type: 'application/zip', filename: 'reports.zip')
	end

	def create_zip
		Zip::File.open('reports.zip', Zip::File::CREATE) { |zipfile|
			zipfile.get_output_stream("DTR Summary Sheet.xls") { |summary|
			    Employee.all.each do |emp|
			    	next if emp.falco_id.nil? && emp.biometrics_id.nil?
					zipfile.get_output_stream("#{emp.last_name}_#{emp.first_name}.xls") { |f| 
						f.puts(to_csv(emp))
					}
				end
			}
		}
	end

	def to_csv(emp)
		@@hours_late = 0
		@@times_late = 0
		@@hours_ot = 0
		@@times_vl = 0
		@@times_sl = 0
		@date_start = '2015-03-21'.to_date
		@date_end = '2015-04-03'.to_date
		@date = @date_start 
		CSV.generate do |csv|
			csv << ["iRipple, Inc."]
			csv << ["Name: #{emp.last_name}, #{emp.first_name}"]
			csv << ["Department: #{emp.department}"]
			csv << ["DATE", "DAY", "TIME IN", "TIME OUT", "UT DEPARTURE", "NO OF HRS LATE", "NO OF OT HOURS", "VL", "SL", "REMARKS"]
			while @date < @date_end
				@attendance = Attendance.where(employee_id: emp.id, attendance_date: @date).first
				@req = Request.where(employee_id: emp.id, date: @date).first
				if !@attendance.nil? && (@attendance.time_in.strftime('%H:%M:%S').to_time > '08:30:00'.to_time)
					@@hours_late += ((@attendance.time_in.strftime('%H:%M:%S').to_time - '08:30:00'.to_time)/1.hour)
					@@times_late += 1
				end
				if !@req.nil?
					@@hours_ot += @req.ot_hours.to_d if !@req.ot_hours.nil?
					@@times_vl += @req.vacation_leave.to_d if !@req.vacation_leave.nil?
					@@times_sl += @req.sick_leave.to_d if !@req.sick_leave.nil?
				end
				    csv << [@req.date.strftime('%m-%d-%Y'),
				    	@req.date.strftime('%A'), 
				    	(@attendance.time_in.to_time.strftime('%H:%M %P') if !@attendance.nil? && !@attendance.time_in.nil?), 
				    	(@attendance.time_out.to_time.strftime('%H:%M %P') if !@attendance.nil? && !@attendance.time_out.nil?), 
				    	@req.ut_time,
				    	(((@attendance.time_in.strftime('%H:%M:%S').to_time - '08:30:00'.to_time)/1.hour).round(2) if !@attendance.nil? && !@attendance.time_in.nil? && @attendance.time_in.strftime('%H:%M:%S').to_time > '08:30:00'.to_time),
				    	@req.ot_hours,
				    	@req.vacation_leave,
				    	@req.sick_leave,
				    	@req.remarks]
	        	@date += 1.day
	        end
	        csv << [" ", " ", " ", " ", "NUMBER OF TIMES TARDY", @@times_late]
	        csv << [" ", " ",  " ", " ", "TOTAL TARDINESS", @@hours_late.round(2)]
	        csv << [" ", " ", " ", " ", " ", "TOTAL OT HOURS", @@hours_ot.round(2)]
	        csv << [" ", " ", " ", " ", " ", " ", "TOTAL LEAVES ACCUMULATED", @@times_vl.round(2), @@times_sl.round(2)]
	        csv << [" "]

	        @@ot_days = (@@hours_ot/8).to_s.split('.').first
	        @@ot_hours = (@@hours_ot%8).to_s.split('.').first
       		@@ot_mins = "#{((((@@hours_ot%8).round(2)).to_s.split('.').last).to_d * 0.6).to_s.split('.').first}"
	       	@@late_days = (@@hours_late/8).to_s.split('.').first
	       	@@late_hours = (@@hours_late%8).to_s.split('.').first
       		@@late_mins = "#{((((@@hours_late%8).round(2)).to_s.split('.').last).to_d * 0.6).to_s.split('.').first}"
	        csv << ["ACCUMULATED OT", "#{@@ot_days}.#{@@ot_hours}.#{@@ot_mins}"]
	        csv << ["LATES", "#{@@late_days}.#{@@late_hours}.#{@@late_mins}"]
	        csv << ["ACCUMULATED VL", " "]
	        csv << ["ACCUMULATED SL", " "]
	        csv << ["VL BALANCE", " "]
	        csv << ["SL BALANCE", " "]
	        csv << ["TOTAL", " "]
		end
	end

  	def import 
  		Attendance.import(params[:biometrics], params[:falco])
  		Request.import(params[:file])
   		redirect_to reports_path, notice: 'Files Imported!' 
	end
end
