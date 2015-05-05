include FileUtils
require 'csv'
require 'pathname'
require 'rubygems'
require 'zip'
require 'axlsx'
class ReportsController < ApplicationController

	def index
		# @biometrics = true
	end

	def download_zip
	  	File.delete(Rails.root + 'reports.zip') if File.exists?(Rails.root + 'reports.zip')
	  	
	  	iEMS_path = Rails.root.join('public', 'uploads', 'iEMS.csv')
	  	biometrics_path = Rails.root.join('public', 'uploads','biometrics.csv')
	  	falco_path = Rails.root.join('public', 'uploads','falco.txt')

	  	Request.import(iEMS_path) if File.exists?(iEMS_path)
	  	Attendance.import(biometrics_path) if File.exists?(biometrics_path)
	  	Attendance.import(falco_path) if File.exists?(falco_path)

	 	# @date_start = params[:date_start]
	 	# @date_end = params[:date_end]

	 	File.delete(biometrics_path) if File.exists?(biometrics_path)
	 	File.delete(falco_path) if File.exists?(falco_path)
	 	File.delete(iEMS_path) if File.exists?(iEMS_path)
		
		zip = create_zip
	 	send_file(Rails.root.join('reports.zip'), type: 'application/zip', filename: 'reports.zip')
	end

	def create_zip
		Zip::File.open('reports.zip', Zip::File::CREATE) { |zipfile|


			zipfile.get_output_stream("DTR Summary Sheet.xls") { |summary|
				summary.puts(CSV.generate do |summarycsv| #CREATE DTR SUMMARY
					summarycsv << ["iRipple, Inc."]
					summarycsv << [" ", "DTR Summary Sheet for the period March 21, 2015, to April 03, 2015", "TARDINESS", "TARDINESS", "TARDINESS", "SL", "SL", "VL", "VL", "TOTAL DEDUCTION", "OT", "OT", "OT", "OT", "OT"]
					summarycsv << ["NO.", 
								   "NAME", 
								   "FREQUENCY", 
								   "NO. OF HOURS", 
								   "UNDERTIME", 
								   "CREDITS", 
								   "BALANCE", 
								   "CREDITS", 
								   "BALANCE", 
								   "(TARDINESS + \n LEAVE + \n UNDERTIME)", 
								   "REGULAR",
								   "RESTDAY",
								   "HOLIDAY",
								   "ALLOWANCE",
								   "TOTAL"]
	
				    Employee.find_by_sql("SELECT * FROM employees ORDER BY last_name").each_with_index do |emp, i|


				    	next if emp.falco_id.nil? && emp.biometrics_id.nil?
						zipfile.get_output_stream("Employees/#{emp.last_name}_#{emp.first_name}.xls") { |f| 
							f.puts(to_csv(emp)) #CREATE XLS PER EMPLOYEE
						}


						summarycsv << [i+1, 
									"#{emp.last_name},#{emp.first_name}", 
									"#{@@times_late}", 
									"#{@@late_days}.#{@@late_hours}.#{@@late_mins}",
									" ",
									"#{@@sl_days}.#{@@sl_hours}.0",
									" ",
									"#{@@vl_days}.#{@@vl_hours}.0",
									" ",
									" ",
									" ",
									" ",
									" ",
									" ",
									" ",
									" "]
					end
				end)
			}
		}
	end

	def to_csv(emp)
		@@hours_late = 0
		@@times_late = 0
		@@hours_ot = 0
		@@times_vl = 0
		@@times_sl = 0
		@@ut_total = 0
		@date_start = '2015-03-21'.to_date
		@date_end = '2015-04-03'.to_date
		@date = @date_start 

		CSV.generate do |csv|
			csv << ["iRipple, Inc."]
			csv << ["Name: #{emp.last_name}, #{emp.first_name}"]
			csv << ["Department: #{emp.department}"]
			csv << ["DATE", "DAY", "TIME IN", "TIME OUT", "UT DEPARTURE", "NO OF HRS LATE", "NO OF OT HOURS", "VL", "SL", "REMARKS"]
			# while @date < @date_end
			# Request.find_by_sql("SELECT * FROM requests WHERE employee_id = '#{emp.id}' ORDER BY date").each do |req|

			Request.where(employee_id: emp.id).each do |req|
				@attendance = Attendance.where(employee_id: emp.id, attendance_date: req.date).first

				if !@attendance.nil? && (@attendance.time_in.strftime('%H:%M:%S').to_time > '08:30:00'.to_time)
					@@hours_late += ((@attendance.time_in.strftime('%H:%M:%S').to_time - '08:30:00'.to_time)/1.hour)
					@@times_late += 1
				end

				@@hours_ot += req.regular_ot.to_d if !req.regular_ot.nil?
				@@times_vl += req.vacation_leave.to_d if !req.vacation_leave.nil?
				@@times_sl += req.sick_leave.to_d if !req.sick_leave.nil?

				# if !@attendance.nil? && (@attendance.time_out.strftime('%H:%M:%S').to_time < '6:30:00'.to_time)
				# 	@@hours_late += ((@attendance.time_in.strftime('%H:%M:%S').to_time - '08:30:00'.to_time)/1.hour)
				# 	@@times_late += 1
				# end 					FOR UNDERTIME COMPUTATION

				    csv << [req.date.strftime('%m-%d-%Y'),
				    	req.date.strftime('%A'), 
				    	(@attendance.time_in.to_time.strftime('%H:%M %P') if !@attendance.nil? && !@attendance.time_in.nil?), 
				    	(@attendance.time_out.to_time.strftime('%H:%M %P') if !@attendance.nil? && !@attendance.time_out.nil?), 
				    	req.ut_time,
				    	(((@attendance.time_in.strftime('%H:%M:%S').to_time - '08:30:00'.to_time)/1.hour).round(2) if !@attendance.nil? && !@attendance.time_in.nil? && @attendance.time_in.strftime('%H:%M:%S').to_time > '08:30:00'.to_time),
				    	req.regular_ot,
				    	req.vacation_leave,
				    	req.sick_leave,
				    	req.remarks]
	        	# @date += 1.day #FOR USING DATE START AND DATE END AS BASIS FOR LOOP
        	end
	        # end #FOR USING DATE START AND DATE END AS BASIS FOR LOOP

	        csv << [" ", " ", " ", " ", "NUMBER OF TIMES TARDY", @@times_late]
	        csv << [" ", " ",  " ", " ", "TOTAL TARDINESS", @@hours_late.to_d.round(2)]
	        csv << [" ", " ", " ", " ", " ", "TOTAL OT HOURS", @@hours_ot.to_d.round(2)]
	        csv << [" ", " ", " ", " ", " ", " ", "TOTAL LEAVES ACCUMULATED", @@times_vl.to_d.round(2), @@times_sl.to_d.round(2)]
	        csv << [" "]

	        @@ot_days = (@@hours_ot/8).to_s.split('.').first
	        @@ot_hours = (@@hours_ot%8).to_s.split('.').first
       		@@ot_mins = "#{((((@@hours_ot%8).round(2)).to_s.split('.').last).to_d * 0.6).to_s.split('.').first}"
	       	@@late_days = (@@hours_late/8).to_s.split('.').first
	       	@@late_hours = (@@hours_late%8).to_s.split('.').first
       		@@late_mins = "#{((((@@hours_late%8).round(2)).to_s.split('.').last).to_d * 0.6).to_s.split('.').first}"
       		@@vl_days = @@times_vl.to_s.split('.').first
       		@@vl_hours = ((@@times_vl.to_s.split('.').last).to_d * 0.8).to_s.split('.').first
       		@@sl_days = @@times_sl.to_s.split('.').first
       		@@sl_hours = ((@@times_sl.to_s.split('.').last).to_d * 0.8).to_s.split('.').first
	        csv << ["ACCUMULATED OT", "#{@@ot_days}.#{@@ot_hours}.#{@@ot_mins}"]
	        csv << ["LATES", "#{@@late_days}.#{@@late_hours}.#{@@late_mins}"]
	        csv << ["ACCUMULATED VL", "#{@@vl_days}.#{@@vl_hours}.0"]
	        csv << ["ACCUMULATED SL", "#{@@sl_days}.#{@@sl_hours}.0"]
	        csv << ["VL BALANCE", " "]
	        csv << ["SL BALANCE", " "]
	        csv << ["TOTAL", " "]
		end
	end

  	def import
  		post = Report.save(params[:biometrics], params[:falco], params[:iEMS])	
   		# @@biometrics_file = true unless params[:biometrics].nil?
   		redirect_to reports_path, notice: 'Files Imported!' 
	end
end

# <<<<<<< Updated upstream
# 	 #  	File.delete(Rails.root + 'reports.zip') if File.exists?(Rails.root + 'reports.zip')
# 	 #  	# @date_start = params[:date_start]
# 	 #  	# @date_end = params[:date_end]
# 	 #  	# puts "==============================================="
# 	 #  	# puts "#{@date_start}"
# 	 #  	# puts "#{@date_end}"
# 	 #  	# puts "==============================================="
# 		# zip = create_zip

# 	p = Axlsx::Package.new
	 
# 	# Required for use with numbers
# 	p.use_shared_strings = true
	 
# 	p.workbook do |wb|
# 	  # define your regular styles
# 	  styles = wb.styles
# 	  title = styles.add_style :sz => 15, :b => true, :u => true
# 	  default = styles.add_style :border => Axlsx::STYLE_THIN_BORDER
# 	  pascal_colors = { :bg_color => '567DCC', :fg_color => 'FFFF00' }
# 	  pascal = styles.add_style pascal_colors.merge({ :border => Axlsx::STYLE_THIN_BORDER, :b => true })
# 	  header = styles.add_style :bg_color => '00', :fg_color => 'FF', :b => true
# 	  money = styles.add_style :format_code => '#,###,##0', :border => Axlsx::STYLE_THIN_BORDER
# 	  money_pascal = styles.add_style pascal_colors.merge({ :format_code => '#,###,##0', :border => Axlsx::STYLE_THIN_BORDER })
# 	  percent = styles.add_style :num_fmt => Axlsx::NUM_FMT_PERCENT, :border => Axlsx::STYLE_THIN_BORDER
# 	  percent_pascal = styles.add_style pascal_colors.merge({ :num_fmt => Axlsx::NUM_FMT_PERCENT, :border => Axlsx::STYLE_THIN_BORDER })
	 
# 	  wb.add_worksheet(:name => 'Data Bar Conditional Formatting') do  |ws|
# 	    ws.add_row ['A$$le Q1 Revenue Historical Analysis (USD)'], :style => title
# 	    ws.add_row
# 	    ws.add_row ['Quarter', 'Profit', '% of Total'], :style => header
# 	    # Passing one style applies the style to all columns
# 	    ws.add_row ['Q1-2010', '15680000000', '=B4/SUM(B4:B7)'], :style => pascal
	 
# 	    # Otherwise you can specify a style for each column.
# 	    ws.add_row ['Q1-2011', '26740000000', '=B5/SUM(B4:B7)'], :style => [pascal, money_pascal, percent_pascal]
# 	    ws.add_row ['Q1-2012', '46330000000', '=B6/SUM(B4:B7)'], :style => [default, money, percent]
# 	    ws.add_row ['Q1-2013(est)', '72230000000', '=B7/SUM(B4:B7)'], :style => [default, money, percent]
	 
# 	    # You can merge cells!
# 	    ws.merge_cells 'A1:C1'
	 
# 	  end
# 	end
# 	p.serialize 'getting_barred.xlsx'
# 	  	send_file(Rails.root.join('reports.zip'), type: 'application/zip', filename: 'reports.zip')
# =======