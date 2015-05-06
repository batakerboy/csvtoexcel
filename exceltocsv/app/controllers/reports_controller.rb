include FileUtils
require 'csv'
require 'pathname'
require 'rubygems'
require 'zip'
require 'axlsx'
class ReportsController < ApplicationController

	def index
	end

	def view_all(date_start, date_end)
		@employees = Employee.all
		# .each do |employee|
		# 	date = date_start
		# 	while date <= date_end
		# 		get_employee_performance
		# 		@date += 1.day
		# 	end
		# end
	end

	def generate_report
		# iEMS_path = Rails.root.join('public', 'uploads', 'iEMS.csv')
	 #  	biometrics_path = Rails.root.join('public', 'uploads','biometrics.csv')
	 #  	falco_path = Rails.root.join('public', 'uploads','falco.txt')

	 #  	# Request.import(iEMS_path) if File.exists?(iEMS_path)
	 #  	# Attendance.import(biometrics_path) if File.exists?(biometrics_path)
	 #  	# Attendance.import(falco_path) if File.exists?(falco_path)

	 #  	# if :date_start.nil?
	 #  		token = File.open(Rails.root.join('public', 'uploads', 'iEMS.csv'), &:readline).split(',')
	 #  		redirect_to download_zip_reports_path
	 #  		# (date_start: token[1].to_date, date_end: token[3].to_date)
	 #  	# end
	end
	def download_zip
		# (date_start, date_end)
	  	File.delete(Rails.root + 'reports.zip') if File.exists?(Rails.root + 'reports.zip')
	  	
	  	# iEMS_path = Rails.root.join('public', 'uploads', 'iEMS.csv')
	  	# biometrics_path = Rails.root.join('public', 'uploads','biometrics.csv')
	  	# falco_path = Rails.root.join('public', 'uploads','falco.txt')

	  	# Request.import(iEMS_path) if File.exists?(iEMS_path)
	  	# Attendance.import(biometrics_path) if File.exists?(biometrics_path)
	  	# Attendance.import(falco_path) if File.exists?(falco_path)
		
		zip = create_zip
		# (date_start: date_start, date_end: date_end)
	 	send_file(Rails.root.join('reports.zip'), type: 'application/zip', filename: @@filename)
	end

	def create_zip
		# (date_start=nil, date_end=nil)
		# if :date_start.nil? && :date_end.nil?
		# 	token = File.open(Rails.root.join('public', 'uploads', 'iEMS.csv'), &:readline).split(',')
		#   	@date_start = token[1].to_date
		#   	@date_end = token[3].to_date
		# else
		#  	@date_start = :date_start
		#  	@date_end = :date_end
		# end
		token = File.open(Rails.root.join('public', 'uploads', 'iEMS.csv'), &:readline).split(',')
		  	@date_start = token[1].to_date
		  	@date_end = token[3].to_date

	  	@@filename = "DTR for #{@date_start} to #{@date_end}.zip"

		Zip::File.open('reports.zip', Zip::File::CREATE) { |zipfile|

			zipfile.get_output_stream("DTR Summary Sheet.xls") { |summary|
				summary.puts(CSV.generate do |summarycsv| #CREATE DTR SUMMARY
					summarycsv << ["iRipple, Inc."]
					summarycsv << [" ", "DTR Summary Sheet for the period \n #{@date_start}, to #{@date_end}", "TARDINESS", "TARDINESS", "TARDINESS", "SL", "SL", "VL", "VL", "TOTAL DEDUCTION", "OT", "OT", "OT", "OT", "OT", "OT", "OT", "OT", "OT", "OT", "OT"]
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
								   "REGULAR DAY",
								   "REST DAY OR \n SPECIAL PUBLIC HOLIDAY",
								   "REST DAY OR \n SPECIAL PUBLIC HOLIDAY EXCESS 8 HRS",
								   "SPECIAL PUBLIC HOLIDAY \n ON REST DAY",
								   "SPECIAL PUBLIC HOLIDAY \n ON REST DAY EXCESS 8 HRS",
								   "REGULAR HOLIDAY",
								   "REGULAR HOLIDAY \n EXCESS 8 HRS",
								   "REGULAR HOLIDAY ON REST DAY",
								   "REGULAR HOLIDAY ON REST DAY \n EXCESS 8 HRS",
								   "ALLOWANCE",
								   "TOTAL"]
	
				    Employee.find_by_sql("SELECT * FROM employees ORDER BY last_name").each_with_index do |emp, i|

				    	next if emp.falco_id.nil? && emp.biometrics_id.nil?
						zipfile.get_output_stream("Employees/#{emp.last_name}_#{emp.first_name}.xls") { |f| 
							f.puts(to_csv(emp, @date_start, @date_end)) #CREATE XLS PER EMPLOYEE
						}

						summarycsv << [i+1, 
									"#{emp.last_name},#{emp.first_name}", 
									"#{@@times_late}", 
									"#{@@late_days}.#{@@late_hours}.#{@@late_mins}",
									"#{@@ut_days}.#{@@ut_hours}.#{@@ut_mins}",
									"#{@@sl_days}.#{@@sl_hours}.0",
									"#{@@sl_balance_start_days}.#{@@sl_balance_start_hours}.0",
									"#{@@vl_days}.#{@@vl_hours}.0",
									"#{@@vl_balance_start_days}.#{@@vl_balance_start_hours}.0",
									" ",
									"#{@@reg_ot_days}.#{@@reg_ot_hours}.#{@@reg_ot_mins}",
									"#{@@rest_or_special_ot_first8_days}.#{@@rest_or_special_ot_first8_hours}.#{@@rest_or_special_ot_first8_mins}",
									("#{@@rest_or_special_ot_excess8_days}.#{@@rest_or_special_ot_excess8_hours}.#{@@rest_or_special_ot_excess8_mins}" if @@rest_or_special_ot_total > 8),
									"#{@@special_on_rest_ot_first8_days}.#{@@special_on_rest_ot_first8_hours}.#{@@special_on_rest_ot_first8_mins}",
									("#{@@special_on_rest_ot_excess8_days}.#{@@special_on_rest_ot_excess8_hours}.#{@@special_on_rest_ot_excess8_mins}" if @@special_on_rest_ot_total > 8),
									"#{@@regular_holiday_ot_first8_days}.#{@@regular_holiday_ot_first8_hours}.#{@@regular_holiday_ot_first8_mins}",
									("#{@@regular_holiday_ot_excess8_days}.#{@@regular_holiday_ot_excess8_hours}.#{@@regular_holiday_ot_excess8_mins}" if @@regular_holiday_ot_total > 8),
									"#{@@regular_on_rest_ot_first8_days}.#{@@regular_on_rest_ot_first8_hours}.#{@@regular_on_rest_ot_first8_mins}",
									("#{@@regular_on_rest_ot_excess8_days}.#{@@regular_on_rest_ot_excess8_hours}.#{@@regular_on_rest_ot_excess8_mins}" if @@regular_on_rest_ot_total > 8),
									" ",
									"#{@@total_ot_days}.#{@@total_ot_hours}.#{@@total_ot_mins}"]
					end
				end)
			}
		}

		iEMS_path = Rails.root.join('public', 'uploads', 'iEMS.csv')
	  	biometrics_path = Rails.root.join('public', 'uploads','biometrics.csv')
	  	falco_path = Rails.root.join('public', 'uploads','falco.txt')

	# 	File.delete(biometrics_path) if File.exists?(biometrics_path)
	#  	File.delete(falco_path) if File.exists?(falco_path)
	#  	File.delete(iEMS_path) if File.exists?(iEMS_path)
	end

	def to_csv(emp, date_start, date_end)
		@@hours_late = 0
		@@times_late = 0
		@@hours_ot = 0
		@@times_vl = 0
		@@times_sl = 0
		@@ut_total = 0
		@@vl_balance_start = Request.where(employee_id: emp.id).first.vacation_leave_balance
		@@sl_balance_start = Request.where(employee_id: emp.id).first.sick_leave_balance

		@@vl_balance_start_days = @@vl_balance_start.to_s.split('.').first
		@@vl_balance_start_hours = (((@@vl_balance_start.to_s.split('.').last).to_i)*0.8).to_i

		@@sl_balance_start_days = @@sl_balance_start.to_s.split('.').first
		@@sl_balance_start_hours = (((@@sl_balance_start.to_s.split('.').last).to_i)*0.8).to_i

		@@reg_ot_total = 0
		@@rest_or_special_ot_total = 0
		@@special_on_rest_ot_total = 0
		@@regular_holiday_ot_total = 0
		@@regular_on_rest_ot_total = 0	

		@date = date_start
		@@cutoff_date = '2015-04-01'.to_date

		CSV.generate do |csv|
			csv << ["iRipple, Inc."]
			csv << ["Name: #{emp.last_name}, #{emp.first_name}"]
			csv << ["Department: #{emp.department}"]
			csv << ["DATE", "DAY", "TIME IN", "TIME OUT", "UT DEPARTURE", "NO OF HRS LATE", "NO OF OT HOURS", "VL", "SL", "REMARKS"]
			while @date <= date_end

				# Request.find_by_sql("SELECT * FROM requests WHERE employee_id = '#{emp.id}' ORDER BY date").each do |req|
				# Request.where(employee_id: emp.id).each do |req|
				@attendance = Attendance.where(employee_id: emp.id, attendance_date: @date).first
				@req = Request.where(employee_id: emp.id, date: @date).first

				if !@attendance.nil? && (@attendance.time_in.strftime('%H:%M:%S').to_time > '08:30:00'.to_time)
					@@hours_late += ((@attendance.time_in.strftime('%H:%M:%S').to_time - '08:30:00'.to_time)/1.hour)
					@@times_late += 1
				end

				@@present_othours = 0

				if !@req.nil?
					if !@req.regular_ot.nil?
						@@present_othours = @req.regular_ot.to_d
						@@reg_ot_total += @req.regular_ot.to_d
					elsif !@req.rest_or_special_ot.nil?
						@@present_othours = @req.rest_or_special_ot.to_d
						@@rest_or_special_ot_total += @req.rest_or_special_ot.to_d
					elsif !@req.special_on_rest_ot.nil?
						@@present_othours = @req.special_on_rest_ot.to_d
						@@special_on_rest_ot_total += @req.special_on_rest_ot.to_d
					elsif !@req.regular_holiday_ot.nil?
						@@present_othours = @req.regular_holiday_ot.to_d
						@@regular_holiday_ot_total += @req.regular_holiday_ot.to_d
					elsif !@req.regular_on_rest_ot.nil?
						@@present_othours = @req.regular_on_rest_ot.to_d
						@@regular_on_rest_ot_total += @req.regular_on_rest_ot.to_d
					end
					
					if @@cutoff_date >= date_start && @@cutoff_date <= date_end
						if @date < @@cutoff_date
							@@times_vl += @req.vacation_leave.to_d if !@req.vacation_leave.nil?
							@@times_sl += @req.sick_leave.to_d if !@req.sick_leave.nil?
						end
					else
						@@times_vl += @req.vacation_leave.to_d if !@req.vacation_leave.nil?
						@@times_sl += @req.sick_leave.to_d if !@req.sick_leave.nil?
					end
				end

				@@hours_ot += @@present_othours

				#FOR UT COMPUTATION
				if !@attendance.nil? && !@attendance.time_out.nil? 
					if !@req.ut_time.nil?
						if @attendance.time_out.to_time.strftime('%H:%M:%S') < @req.ut_time.to_time.strftime('%H:%M:%S')
							@@ut_total += (@req.ut_time.to_time.strftime('%H:%M:%S') - @attendance.time_out.to_time.strftime('%H:%M:%S'))
						end
					else
						if @req.date.strftime('%A').to_s == "Friday"
							if @attendance.time_out.to_time.strftime('%H:%M:%S').to_time < '17:30:00'.to_time
								@@ut_total += '17:30:00'.to_time - @attendance.time_out.to_time.strftime('%H:%M:%S').to_time
							end
						elsif @req.date.strftime('%A').to_s == "Monday" || @req.date.strftime('%A').to_s == "Tuesday" || @req.date.strftime('%A').to_s == "Wednesday" || @req.date.strftime('%A').to_s == "Thursday"
							if @attendance.time_out.to_time.strftime('%H:%M:%S').to_time < '18:30:00'.to_time
								@@ut_total += '18:30:00'.to_time - @attendance.time_out.to_time.strftime('%H:%M:%S').to_time
							end
						end
					end
				end
				
			    csv << [@req.date.strftime('%m-%d-%Y'),
			    	@req.date.strftime('%A'), 
			    	(@attendance.time_in.to_time.strftime('%H:%M:%S') if !@attendance.nil? && !@attendance.time_in.nil?), 
			    	(@attendance.time_out.to_time.strftime('%H:%M:%S') if !@attendance.nil? && !@attendance.time_out.nil?), 
			    	@req.ut_time,
			    	(((@attendance.time_in.strftime('%H:%M:%S').to_time - '08:30:00'.to_time)/1.hour).round(2) if !@attendance.nil? && !@attendance.time_in.nil? && @attendance.time_in.strftime('%H:%M:%S').to_time > '08:30:00'.to_time),
			    	@@present_othours,
			    	@req.vacation_leave,
			    	@req.sick_leave,
			    	@req.remarks]

	        	@date += 1.day #FOR USING DATE START AND DATE END AS BASIS FOR LOOP
        	end

	        csv << [" ", " ", " ", " ", "NUMBER OF TIMES TARDY", @@times_late]
	        csv << [" ", " ",  " ", " ", "TOTAL TARDINESS", @@hours_late.to_f.round(2)]
	        csv << [" ", " ", " ", " ", " ", "TOTAL OT HOURS", @@hours_ot.to_f.round(2)]
	        csv << [" ", " ", " ", " ", " ", " ", "TOTAL LEAVES ACCUMULATED", @@times_vl.to_f.round(2), @@times_sl.to_d.round(2)]
	        csv << [" "]

	        @@total_ot_days = (@@hours_ot/8).to_s.split('.').first
	        @@total_ot_hours = (@@hours_ot%8).to_s.split('.').first
       		@@total_ot_mins = "#{((((@@hours_ot%8).round(2)).to_s.split('.').last).to_d * 0.6).to_s.split('.').first}"

	       	@@late_days = (@@hours_late/8).to_s.split('.').first
	       	@@late_hours = (@@hours_late%8).to_s.split('.').first
       		@@late_mins = "#{((((@@hours_late%8).round(2)).to_s.split('.').last).to_d * 0.6).to_s.split('.').first}"

       		@@vl_days = @@times_vl.to_s.split('.').first
       		@@vl_hours = ((@@times_vl.to_s.split('.').last).to_d * 0.8).to_s.split('.').first

       		@@sl_days = @@times_sl.to_s.split('.').first
       		@@sl_hours = ((@@times_sl.to_s.split('.').last).to_d * 0.8).to_s.split('.').first

	        csv << ["ACCUMULATED OT", "#{@@total_ot_days}.#{@@total_ot_hours}.#{@@total_ot_mins}"]
	        csv << ["LATES", "#{@@late_days}.#{@@late_hours}.#{@@late_mins}"]
	        csv << ["ACCUMULATED VL", "#{@@vl_days}.#{@@vl_hours}.0"]
	        csv << ["ACCUMULATED SL", "#{@@sl_days}.#{@@sl_hours}.0"]
	        csv << ["VL BALANCE", "#{@@vl_balance_start_days}.#{@@vl_balance_start_hours}.0"]
	        csv << ["SL BALANCE", "#{@@sl_balance_start_days}.#{@@sl_balance_start_hours}.0"]
	        csv << ["TOTAL", " "]

	        @@ut_days = ((@@ut_total/3600)/8).to_s.split('.').first
	        @@ut_hours = ((@@ut_total/3600)%8).to_s.split('.').first
       		@@ut_mins = "#{(((((@@ut_total/3600)%8).round(2)).to_s.split('.').last).to_d * 0.6).to_s.split('.').first}"

       		@@reg_ot_days = (@@reg_ot_total/8).to_s.split('.').first
	        @@reg_ot_hours = (@@reg_ot_total%8).to_s.split('.').first
       		@@reg_ot_mins = "#{((((@@reg_ot_total%8).round(2)).to_s.split('.').last).to_d * 0.6).to_s.split('.').first}"

       		if @@rest_or_special_ot_total.to_d > 8
       			@@rest_or_special_ot_excess8_days = ((@@rest_or_special_ot_total.to_d - 8)/8).to_s.split('.').first
       			@@rest_or_special_ot_excess8_hours = ((@@rest_or_special_ot_total.to_d - 8)%8).to_s.split('.').first
       			@@rest_or_special_ot_excess8_mins = "#{((((@@rest_or_special_ot_total.to_d%8).round(2)).to_s.split('.').last).to_d * 0.6).to_s.split('.').first}"
       			@@rest_or_special_ot_first8_days = 1
       			@@rest_or_special_ot_first8_mins = 0
       			@@rest_or_special_ot_first8_hours = 0
   			else
   				@@rest_or_special_ot_first8_days = (@@rest_or_special_ot_total.to_d/8).to_s.split('.').first
       			@@rest_or_special_ot_first8_mins = (@@rest_or_special_ot_total.to_d%8).to_s.split('.').first
       			@@rest_or_special_ot_first8_hours = "#{((((@@rest_or_special_ot_total.to_d%8).round(2)).to_s.split('.').last).to_d * 0.6).to_s.split('.').first}"
   			end

   			if @@special_on_rest_ot_total.to_d > 8
       			@@special_on_rest_ot_excess8_days = ((@@special_on_rest_ot_total.to_d - 8)/8).to_s.split('.').first
       			@@special_on_rest_ot_excess8_hours = ((@@special_on_rest_ot_total.to_d - 8)%8).to_s.split('.').first
       			@@special_on_rest_ot_excess8_mins = "#{((((@@special_on_rest_ot_total.to_d%8).round(2)).to_s.split('.').last).to_d * 0.6).to_s.split('.').first}"
       			@@special_on_rest_ot_first8_days = 1
       			@@special_on_rest_ot_first8_mins = 0
       			@@special_on_rest_ot_first8_hours = 0
   			else
   				@@special_on_rest_ot_first8_days = (@@special_on_rest_ot_total/8).to_s.split('.').first
       			@@special_on_rest_ot_first8_mins = (@@special_on_rest_ot_total%8).to_s.split('.').first
       			@@special_on_rest_ot_first8_hours = "#{((((@@special_on_rest_ot_total.to_d%8).round(2)).to_s.split('.').last).to_d * 0.6).to_s.split('.').first}"
   			end

   			if @@regular_holiday_ot_total.to_d > 8
       			@@regular_holiday_ot_excess8_days = ((@@regular_holiday_ot_total.to_d - 8)/8).to_s.split('.').first
       			@@regular_holiday_ot_excess8_hours = ((@@regular_holiday_ot_total.to_d - 8)%8).to_s.split('.').first
       			@@regular_holiday_ot_excess8_mins = "#{((((@@regular_holiday_ot_total.to_d%8).round(2)).to_s.split('.').last).to_d * 0.6).to_s.split('.').first}"
       			@@regular_holiday_ot_first8_days = 1
       			@@regular_holiday_ot_first8_mins = 0
       			@@regular_holiday_ot_first8_hours = 0
   			else
   				@@regular_holiday_ot_first8_days = (@@regular_holiday_ot_total.to_d/8).to_s.split('.').first
       			@@regular_holiday_ot_first8_mins = (@@regular_holiday_ot_total.to_d%8).to_s.split('.').first
       			@@regular_holiday_ot_first8_hours = "#{((((@@regular_holiday_ot_total.to_d%8).round(2)).to_s.split('.').last).to_d * 0.6).to_s.split('.').first}"
   			end

   			if @@regular_on_rest_ot_total.to_d > 8
       			@@regular_on_rest_ot_excess8_days = ((@@regular_on_rest_ot_total.to_d - 8)/8).to_s.split('.').first
       			@@regular_on_rest_ot_excess8_hours = ((@@regular_on_rest_ot_total.to_d - 8)%8).to_s.split('.').first
       			@@regular_on_rest_ot_excess8_mins = "#{((((@@regular_on_rest_ot_total.to_d%8).round(2)).to_s.split('.').last).to_d * 0.6).to_s.split('.').first}"
       			@@regular_on_rest_ot_first8_days = 1
       			@@regular_on_rest_ot_first8_mins = 0
       			@@regular_on_rest_ot_first8_hours = 0
   			else
   				@@regular_on_rest_ot_first8_days = (@@regular_on_rest_ot_total.to_d/8).to_s.split('.').first
       			@@regular_on_rest_ot_first8_mins = (@@regular_on_rest_ot_total.to_d%8).to_s.split('.').first
       			@@regular_on_rest_ot_first8_hours = "#{((((@@regular_on_rest_ot_total.to_d%8).round(2)).to_s.split('.').last).to_d * 0.6).to_s.split('.').first}"
   			end
		end
	end

  	def import
  		post = Report.save(params[:biometrics], params[:falco], params[:iEMS])	
   		# @@biometrics_file = true unless params[:biometrics].nil?
   		redirect_to reports_path, notice: 'Files Imported!' 
	end
end

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
