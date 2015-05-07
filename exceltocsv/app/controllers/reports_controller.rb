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
		@@reports_zip_path = Rails.root.join('public', 'reports','reports.zip')
	  	File.delete(@@reports_zip_path) if File.exists?(@@reports_zip_path)

	  	@@dtr_summary_path = Rails.root.join('public', 'reports','DTRSUMMARY.xlsx')
		File.delete(@@dtr_summary_path) if File.exists?(@@dtr_summary_path)
		zip = create_zip
		# (date_start: date_start, date_end: date_end)
	 	send_file(@@reports_zip_path, type: 'application/zip', filename: @@filename)
	end



	def create_zip

		token = File.open(Rails.root.join('public', 'uploads', 'iEMS.csv'), &:readline).split(',')
		  	@date_start = token[1].to_date
		  	@date_end = token[3].to_date

	  	@@filename = "DTR for #{@date_start.strftime('%B %d, %Y')} to #{@date_end.strftime('%B %d, %Y')}.zip"

		Zip::File.open(@@reports_zip_path, Zip::File::CREATE) { |zipfile|

			summarydtr = Axlsx::Package.new
	 
			# Required for use with numbers
			summarydtr.use_shared_strings = true
			 
			summarydtr.workbook do |summarydtr_wb|
			# define your regular styles
				styles = summarydtr_wb.styles
				title = styles.add_style sz: 15, b: true, u: true
				headers = styles.add_style sz: 11, b: true, border: {:style => :thin, :color => '00000000', :edges => [:top, :left, :right, :bottom] }, alignment: { :horizontal => :center, :vertical => :center, :wrap_text => true}
				tabledata = styles.add_style sz: 11, border: {:style => :thin, :color => '00000000', :edges => [:top, :left, :right, :bottom] }, alignment: { :horizontal => :center, :vertical => :center, :wrap_text => true}

				summarydtr_wb.add_worksheet(:name => 'DTR SUMMARY') do  |summarydtr_ws|
					summarydtr_ws.add_row ['iRipple, Inc.'], style: title
				    summarydtr_ws.add_row ["DTR Summary Sheet for the period #{@date_start.strftime('%B %d, %Y')} to #{@date_end.strftime('%B %d, %Y')}"," ",
				    					   "TARDINESS", " ", " ",
				    					   "SL", " ",
				    					   "VL", " ",
				    					   "TOTAL DEDUCTION",
				    					   "OT", " ", " ", " ", " ", " ", " ", " ", " ", " ", " "], style: headers
				    summarydtr_ws.add_row ["NO.","NAME",
				    					   "FREQUENCY", "NO. OF HOURS", "UNDERTIME",
				    					   "CREDITS", "BALANCE",
				    					   "CREDITS", "BALANCE",
				    					   "TARDINESS + LEAVE + UNDERTIME",
				    					   "REGULAR DAY", 
				    					   "REST DAY OR SPECIAL PUBLIC HOLIDAY", "REST DAY OR SPECIAL PUBLIC HOLIDAY EXCESS 8 HOURS", 
				    					   "SPECIAL PUBLIC HOLIDAY ON REST DAY", "SPECIAL PUBLIC HOLIDAY ON REST DAY EXCESS 8 HOURS", 
				    					   "REGULAR HOLIDAY", "REGULAR HOLIDAY EXCESS 8 HOURS", 
				    					   "REGULAR HOLIDAY ON REST DAY", "REGULAY HOLIDAY ON REST DAY EXCESS 8 HOURS", 
				    					   "ALLOWANCE", "TOTAL"], style: headers

				    # Otherwise you can specify a style for each column.
				    # summarydtr_ws.add_row ['Q1-2011', '26740000000', '=B5/SUM(B4:B7)'], style: [pascal, money_pascal, percent_pascal]

				    # You can merge cells!
				    summarydtr_ws.merge_cells 'A1:U1'
				    summarydtr_ws.merge_cells 'A2:B2'
				    summarydtr_ws.merge_cells 'C2:E2'
				    summarydtr_ws.merge_cells 'F2:G2'
				    summarydtr_ws.merge_cells 'H2:I2'
				    summarydtr_ws.merge_cells 'K2:U2'


				    Employee.find_by_sql("SELECT * FROM employees ORDER BY last_name").each_with_index do |emp, i|
				    	@@employeedtr_filename = "#{emp.last_name},#{emp.first_name}.xlsx"
				    	@@dtr_peremployee_path = Rails.root.join('public', 'reports', 'employee dtr', @@employeedtr_filename)
						File.delete(@@dtr_peremployee_path) if File.exists?(@@dtr_peremployee_path)

				    	next if emp.falco_id.nil? && emp.biometrics_id.nil?

				    	employeedtr = Axlsx::Package.new
	 
						# Required for use with numbers
						employeedtr.use_shared_strings = true
						 
						employeedtr.workbook do |employeedtr_wb|
						# define your regular styles
							styles = employeedtr_wb.styles
							title = styles.add_style sz: 15, b: true, u: true
							headers = styles.add_style sz: 11, b: true, border: {:style => :thin, :color => '00000000', :edges => [:top, :left, :right, :bottom] }, alignment: { :horizontal => :center, :vertical => :center, :wrap_text => true}
							tabledata = styles.add_style sz: 11, border: {:style => :thin, :color => '00000000', :edges => [:top, :left, :right, :bottom] }, alignment: { :horizontal => :center, :vertical => :center, :wrap_text => true}


							employeedtr_wb.add_worksheet(:name => 'EMPLOYEE DTR') do  |employeedtr_ws|
								employeedtr_ws.add_row ['iRipple, Inc.'], style: title
								employeedtr_ws.add_row ["Name: #{emp.last_name},#{emp.first_name}"], style: title
								employeedtr_ws.add_row ["Department: #{emp.department}"], style: title
				   				employeedtr_ws.add_row ["DATE",
							    					   "DAY",
							    					   "TIME IN",
							    					   "TIME OUT",
							    					   "UT DEPARTURE",
							    					   "NO OF HOURS LATE", 
							    					   "NO OF OVERTIME HOURS", 
							    					   "VACATION LEAVE", 
							    					   "SICK LEAVE", 
							    					   "REMARKS"], style: headers
	    						employeedtr_ws.merge_cells 'A1:J1'
				    			employeedtr_ws.merge_cells 'A2:J2'
				    			employeedtr_ws.merge_cells 'A3:J3'
								

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

								@date = @date_start
								@@cutoff_date = '2015-04-01'.to_date

								rownum = 5
								while @date <= @date_end

									# Request.find_by_sql("SELECT * FROM requests WHERE employee_id = '#{emp.id}' ORDER BY date").each do |req|
									# Request.where(employee_id: emp.id).each do |req|
									@attendance = Attendance.where(employee_id: emp.id, attendance_date: @date).first
									@req = Request.where(employee_id: emp.id, date: @date).first

									@@nohrs_ut = 0
									#FOR UT COMPUTATION
									if !@attendance.nil? && !@attendance.time_out.nil? 
										if !@req.ut_time.nil?
											if @attendance.time_out.to_time.strftime('%H:%M:%S') < @req.ut_time.to_time.strftime('%H:%M:%S')
												@@numut = ((@req.ut_time.to_time.strftime('%H:%M:%S') - @attendance.time_out.to_time.strftime('%H:%M:%S'))/1.hour)
												if @@numut > 1.25
													@@nohrs_ut = 1.50
												elsif @@numut > 1
													@@nohrs_ut = 1.25
												elsif @@numut > 0.75
													@@nohrs_ut = 1.0
												elsif @@numut > 0.50
													@@nohrs_ut = 0.75
												elsif @@numut > 0.25
													@@nohrs_ut = 0.50
												else 
													@@nohrs_ut = 0.25
												end
												@@ut_total += @@nohrs_ut
											end
										else
											if @attendance.time_out.to_time.strftime('%H:%M:%S').to_time > '16:30:00'.to_time
												if @req.date.strftime('%A').to_s == "Friday"
													if @attendance.time_out.to_time.strftime('%H:%M:%S').to_time < '17:30:00'.to_time
														@@numut = (('17:30:00'.to_time - @attendance.time_out.to_time.strftime('%H:%M:%S').to_time)/1.hour)
														if @@numut > 0.75
															@@nohrs_ut = 1.0
														elsif @@numut > 0.50
															@@nohrs_ut = 0.75
														elsif @@numut > 0.25
															@@nohrs_ut = 0.50
														else 
															@@nohrs_ut = 0.25
														end
														@@ut_total += nohrs_ut
													end
												elsif @req.date.strftime('%A').to_s == "Monday" || @req.date.strftime('%A').to_s == "Tuesday" || @req.date.strftime('%A').to_s == "Wednesday" || @req.date.strftime('%A').to_s == "Thursday"
													if @attendance.time_out.to_time.strftime('%H:%M:%S').to_time < '18:30:00'.to_time
														@@numut = (('18:30:00'.to_time - @attendance.time_out.to_time.strftime('%H:%M:%S').to_time)/1.hour)
														if @@numut > 1.75
															@@nohrs_ut = 2.0
														elsif @@numut > 1.5
															@@nohrs_ut = 1.75
														elsif @@numut > 1.25
															@@nohrs_ut = 1.5
														elsif @@numut > 1
															@@nohrs_ut = 1.25
														elsif @@numut > 0.75
															@@nohrs_ut = 1.0
														elsif @@numut > 0.50
															@@nohrs_ut = 0.75
														elsif @@numut > 0.25
															@@nohrs_ut = 0.50
														else 
															@@nohrs_ut = 0.25
														end
														@@ut_total += @@nohrs_ut
													end
												end
											else
												@req.sick_leave = 0.5 #MARK THIS ROW RED
											end
										end
									end

									#FOR COMPUTING NUMBER OF HOURS LATE
									@@nohrs_late = 0
									if !@attendance.nil?
										if @attendance.time_in.strftime('%H:%M:%S').to_time >= '10:00:00'.to_time
											if @@cutoff_date >= @date_start && @@cutoff_date <= @date_end
												if @date < @@cutoff_date
													@req.sick_leave = 0.5 #MARK THIS ROW RED
												end
											end
										elsif @attendance.time_in.strftime('%H:%M:%S').to_time > '08:30:00'.to_time
											@@numlate = ((@attendance.time_in.strftime('%H:%M:%S').to_time - '08:30:00'.to_time)/1.hour)
											if @@numlate > 0.75
												@@nohrs_late = 1.0
											elsif @@numlate > 0.50
												@@nohrs_late = 0.75
											elsif @@numlate > 0.25
												@@nohrs_late = 0.50
											else 
												@@nohrs_late = 0.25
											end
											@@hours_late += @@nohrs_late
											@@times_late += 1
										end
									end

									#OT HOURS COMPUTATION
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
										
										if @@cutoff_date >= @date_start && @@cutoff_date <= @date_end
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

									employeedtr_ws.add_row [@req.date.strftime('%m-%d-%Y'),
														    @req.date.strftime('%A'),
														    (@attendance.time_in.to_time.strftime('%H:%M:%S') if !@attendance.nil? && !@attendance.time_in.nil?),
														    (@attendance.time_out.to_time.strftime('%H:%M:%S') if !@attendance.nil? && !@attendance.time_out.nil?), 
														    (@@nohrs_ut if @@nohrs_ut != 0),
														    (@@nohrs_late if @@nohrs_late != 0),
														    (@@present_othours if @@present_othours != 0),
														    @req.vacation_leave,
														    @req.sick_leave,
														    @req.remarks], style: tabledata
									rownum += 1
						        	@date += 1.day #FOR USING DATE START AND DATE END AS BASIS FOR LOOP
						    	end

						    	employeedtr_ws.add_row ["NUMBER OF TIMES TARDY", " ", " ", " ", " ", "=COUNT(F5:F#{rownum-1})", " ", " ", " ", " "], style: tabledata
						    	employeedtr_ws.merge_cells "A#{rownum}:E#{rownum}"
						    	employeedtr_ws.merge_cells "G#{rownum}:J#{rownum}"
						    	rownum += 1
						    	employeedtr_ws.add_row ["TOTAL TARDINESS", " ", " ", " ", " ", "=SUM(F5:F#{rownum-2})", " ", " ", " ", " "], style: tabledata
						    	employeedtr_ws.merge_cells "A#{rownum}:E#{rownum}"
						    	employeedtr_ws.merge_cells "G#{rownum}:J#{rownum}"
						    	rownum += 1
						    	employeedtr_ws.add_row ["TOTAL OT HOURS", " ", " ", " ", " ", " ", "=SUM(G5:G#{rownum-3})", " ", " ", " "], style: tabledata
						    	employeedtr_ws.merge_cells "A#{rownum}:F#{rownum}"
						    	employeedtr_ws.merge_cells "H#{rownum}:J#{rownum}"
						    	rownum += 1
						    	employeedtr_ws.add_row ["TOTAL LEAVES ACCUMULATED", " ", " ", " ", " ", " ", " ","=SUM(H5:H#{rownum-4})", "=SUM(I5:I#{rownum-4})", " "], style: tabledata
						    	employeedtr_ws.merge_cells "A#{rownum}:G#{rownum}"
						    	rownum += 1

						    	employeedtr_ws.add_row 
						    	rownum += 1

						        @@total_ot_days = (@@hours_ot/8).to_s.split('.').first
						        @@total_ot_hours = (@@hours_ot%8).to_s.split('.').first
						   		@@total_ot_mins = "#{(((@@hours_ot%8).to_s.split('.').last).to_d * 0.6).to_s.split('.').first}"

						       	@@late_days = (@@hours_late/8).to_s.split('.').first
						       	@@late_hours = (@@hours_late%8).to_s.split('.').first
						   		@@late_mins = "#{(((@@hours_late%8).to_s.split('.').last).to_d * 0.6).to_s.split('.').first}"

						   		@@vl_days = @@times_vl.to_s.split('.').first
						   		@@vl_hours = ((@@times_vl.to_s.split('.').last).to_d * 0.8).to_s.split('.').first

						   		@@sl_days = @@times_sl.to_s.split('.').first
						   		@@sl_hours = ((@@times_sl.to_s.split('.').last).to_d * 0.8).to_s.split('.').first

						   		@@vl_total = 0
						   		@@sl_total = 0

						   		if @@times_vl.to_d > @@vl_balance_start.to_d
						   			@@vl_total = @@times_vl.to_d - @@vl_balance_start.to_d
						   		end

						   		if @@times_sl.to_d > @@sl_balance_start.to_d
						   			@@sl_total = @@times_sl.to_d - @@sl_balance_start.to_d
						   		end

						   		@@total_leave_late = @@vl_total + @@sl_total + @@hours_late

						   		@@total_leave_late_days = (@@total_leave_late/8).to_s.split('.').first
						   		@@total_leave_late_hours = (@@total_leave_late%8).to_s.split('.').first
						   		@@total_leave_late_mins = "#{(((@@total_leave_late%8).to_s.split('.').last).to_d * 0.6).to_s.split('.').first}"

								@@ut_days = (@@ut_total/8).to_s.split('.').first
						        @@ut_hours = (@@ut_total%8).to_s.split('.').first
						   		@@ut_mins = "#{(((@@ut_total%8).to_s.split('.').last).to_d * 0.6).to_s.split('.').first}"


						   		@@total_leave_late_ut = @@total_leave_late + @@ut_total

						   		@@total_leave_late_ut_days = (@@total_leave_late_ut/8).to_s.split('.').first
						   		@@total_leave_late_ut_hours = (@@total_leave_late_ut%8).to_s.split('.').first
						   		@@total_leave_late_ut_mins = "#{(((@@total_leave_late_ut%8).to_s.split('.').last).to_d * 0.6).to_s.split('.').first}"

						   		employeedtr_ws.add_row ["ACCUMULATED OT", ("=FLOOR(G#{rownum-3}/8,1,1)&"<<'"."'<<"&FLOOR(MOD(G#{rownum-3},8),1,1)&"<<'"."'<<"&(MOD(G#{rownum-3},8)-FLOOR(MOD(G#{rownum-3},8),1,1))*60"), " ", " ", " ", " ", " ", " ", " ", " ", 
						   							    "=INT(LEFT(B#{rownum+1},1))", 
						   							    "=RIGHT(B#{rownum+1},LEN(B#{rownum+1})-2)", 
						   							    "=INT(LEFT(L#{rownum},1))", 
						   							    "=RIGHT(L#{rownum},LEN(L#{rownum})-2)+0", 
						   							    "=K#{rownum}*8*60+M#{rownum}*60+N#{rownum}"], style: tabledata
						    	rownum += 1
						    	employeedtr_ws.add_row ["LATES", ("=FLOOR(F#{rownum-5}/8,1,1)&"<<'"."'<<"&FLOOR(MOD(F#{rownum-5},8),1,1)&"<<'"."'<<"&(MOD(F#{rownum-5},8)-FLOOR(MOD(F#{rownum-5},8),1,1))*60"), " ", " ", " ", " ", " ", " ", " ", " ", 
						    							"=INT(LEFT(B#{rownum+1},1))", 
						   							    "=RIGHT(B#{rownum+1},LEN(B#{rownum+1})-2)", 
						   							    "=INT(LEFT(L#{rownum},1))", 
						   							    "=RIGHT(L#{rownum},LEN(L#{rownum})-2)+0", 
						   							    "=K#{rownum}*8*60+M#{rownum}*60+N#{rownum}"], style: tabledata
						    	rownum += 1
						    	employeedtr_ws.add_row ["ACCUMULATED VL", ("=FLOOR(H#{rownum-4},1,1)&"<<'"."'<<"&(H#{rownum-4}-FLOOR(H#{rownum-4},1,1))*8&"<<'".0"'), " ", " ", " ", " ", " ", " ", " ", " ", 
						    							"=INT(LEFT(B#{rownum+1},1))", 
						   							    "=RIGHT(B#{rownum+1},LEN(B#{rownum+1})-2)", 
						   							    "=INT(LEFT(L#{rownum},1))", 
						   							    "=RIGHT(L#{rownum},LEN(L#{rownum})-2)+0", 
						   							    "=K#{rownum}*8*60+M#{rownum}*60+N#{rownum}"], style: tabledata
						    	rownum += 1
						    	employeedtr_ws.add_row ["ACCUMULATED SL", ("=FLOOR(I#{rownum-5},1,1)&"<<'"."'<<"&(I#{rownum-5}-FLOOR(I#{rownum-5},1,1))*8&"<<'".0"'), " ", " ", " ", " ", " ", " ", " ", " ", 
						    							"=INT(LEFT(B#{rownum+1},1))", 
						   							    "=RIGHT(B#{rownum+1},LEN(B#{rownum+1})-2)", 
						   							    "=INT(LEFT(L#{rownum},1))", 
						   							    "=RIGHT(L#{rownum},LEN(L#{rownum})-2)+0", 
						   							    "=K#{rownum}*8*60+M#{rownum}*60+N#{rownum}"], style: tabledata
						    	rownum += 1
						    	employeedtr_ws.add_row ["VL BALANCE", "#{@@vl_balance_start_days}.#{@@vl_balance_start_hours}.0", " ", " ", " ", " ", " ", " ", " ", " ", 
						    							"=INT(LEFT(B#{rownum+1},1))", 
						   							    "=RIGHT(B#{rownum+1},LEN(B#{rownum+1})-2)", 
						   							    "=INT(LEFT(L#{rownum},1))", 
						   							    "=RIGHT(L#{rownum},LEN(L#{rownum})-2)+0", 
						   							    "=K#{rownum}*8*60+M#{rownum}*60+N#{rownum}"], style: tabledata
						    	rownum += 1
						    	employeedtr_ws.add_row ["SL BALANCE", "#{@@sl_balance_start_days}.#{@@sl_balance_start_hours}.0", " ", " ", " ", " ", " ", " ", " ", " ", 
						    							"=K#{rownum-5}+IF(K#{rownum-4}>K#{rownum-2},K#{rownum-4}-K#{rownum-2},0)+IF(K#{rownum-3}>K#{rownum-1},K#{rownum-3}-K#{rownum-1},0)",
						    							" ", 
						    							"=M#{rownum-5}+IF(M#{rownum-4}>M#{rownum-2},M#{rownum-4}-M#{rownum-2},0)+IF(M#{rownum-3}>M#{rownum-1},M#{rownum-3}-M#{rownum-1},0)",
						    							"=N#{rownum-5}+IF(N#{rownum-4}>N#{rownum-2},N#{rownum-4}-N#{rownum-2},0)+IF(N#{rownum-3}>N#{rownum-1},N#{rownum-3}-N#{rownum-1},0)", 
						    							"=O#{rownum-5}+IF(O#{rownum-4}>O#{rownum-2},O#{rownum-4}-O#{rownum-2},0)+IF(O#{rownum-3}>O#{rownum-1},O#{rownum-3}-O#{rownum-1},0)"], style: tabledata
						    	rownum += 1
						    	employeedtr_ws.add_row ["TOTAL", "=FLOOR(K#{rownum}/8,1,1)&"<<'"."'<<"&FLOOR(MOD(K#{rownum},8),1,1)&"<<'"."'<<"&(MOD(K#{rownum},8)-FLOOR(MOD(K#{rownum},8),1,1))*60", " ", " ", " ", " ", " ", " ", " ", " ", 
						    							"=O#{rownum-1}/60"], style: tabledata
						    	rownum += 1

		        				employeedtr_ws.column_info[10].hidden = true
						        employeedtr_ws.column_info[11].hidden = true
						        employeedtr_ws.column_info[12].hidden = true
						        employeedtr_ws.column_info[13].hidden = true
						        employeedtr_ws.column_info[14].hidden = true


								@@reg_ot_days = (@@reg_ot_total/8).to_s.split('.').first
						        @@reg_ot_hours = (@@reg_ot_total%8).to_s.split('.').first
						   		@@reg_ot_mins = "#{(((@@reg_ot_total%8).to_s.split('.').last).to_d * 0.6).to_s.split('.').first}"

						   		if @@rest_or_special_ot_total.to_d > 8
						   			@@rest_or_special_ot_excess8_days = ((@@rest_or_special_ot_total.to_d - 8)/8).to_s.split('.').first
						   			@@rest_or_special_ot_excess8_hours = ((@@rest_or_special_ot_total.to_d - 8)%8).to_s.split('.').first
						   			@@rest_or_special_ot_excess8_mins = "#{(((@@rest_or_special_ot_total.to_d%8).to_s.split('.').last).to_d * 0.6).to_s.split('.').first}"
						   			@@rest_or_special_ot_first8_days = 1
						   			@@rest_or_special_ot_first8_mins = 0
						   			@@rest_or_special_ot_first8_hours = 0
									else
										@@rest_or_special_ot_first8_days = (@@rest_or_special_ot_total.to_d/8).to_s.split('.').first
						   			@@rest_or_special_ot_first8_mins = (@@rest_or_special_ot_total.to_d%8).to_s.split('.').first
						   			@@rest_or_special_ot_first8_hours = "#{(((@@rest_or_special_ot_total.to_d%8).to_s.split('.').last).to_d * 0.6).to_s.split('.').first}"
									end

									if @@special_on_rest_ot_total.to_d > 8
						   			@@special_on_rest_ot_excess8_days = ((@@special_on_rest_ot_total.to_d - 8)/8).to_s.split('.').first
						   			@@special_on_rest_ot_excess8_hours = ((@@special_on_rest_ot_total.to_d - 8)%8).to_s.split('.').first
						   			@@special_on_rest_ot_excess8_mins = "#{(((@@special_on_rest_ot_total.to_d%8).to_s.split('.').last).to_d * 0.6).to_s.split('.').first}"
						   			@@special_on_rest_ot_first8_days = 1
						   			@@special_on_rest_ot_first8_mins = 0
						   			@@special_on_rest_ot_first8_hours = 0
									else
										@@special_on_rest_ot_first8_days = (@@special_on_rest_ot_total/8).to_s.split('.').first
						   			@@special_on_rest_ot_first8_mins = (@@special_on_rest_ot_total%8).to_s.split('.').first
						   			@@special_on_rest_ot_first8_hours = "#{(((@@special_on_rest_ot_total.to_d%8).to_s.split('.').last).to_d * 0.6).to_s.split('.').first}"
									end

									if @@regular_holiday_ot_total.to_d > 8
						   			@@regular_holiday_ot_excess8_days = ((@@regular_holiday_ot_total.to_d - 8)/8).to_s.split('.').first
						   			@@regular_holiday_ot_excess8_hours = ((@@regular_holiday_ot_total.to_d - 8)%8).to_s.split('.').first
						   			@@regular_holiday_ot_excess8_mins = "#{(((@@regular_holiday_ot_total.to_d%8).to_s.split('.').last).to_d * 0.6).to_s.split('.').first}"
						   			@@regular_holiday_ot_first8_days = 1
						   			@@regular_holiday_ot_first8_mins = 0
						   			@@regular_holiday_ot_first8_hours = 0
									else
										@@regular_holiday_ot_first8_days = (@@regular_holiday_ot_total.to_d/8).to_s.split('.').first
						   			@@regular_holiday_ot_first8_mins = (@@regular_holiday_ot_total.to_d%8).to_s.split('.').first
						   			@@regular_holiday_ot_first8_hours = "#{(((@@regular_holiday_ot_total.to_d%8).to_s.split('.').last).to_d * 0.6).to_s.split('.').first}"
									end

									if @@regular_on_rest_ot_total.to_d > 8
						   			@@regular_on_rest_ot_excess8_days = ((@@regular_on_rest_ot_total.to_d - 8)/8).to_s.split('.').first
						   			@@regular_on_rest_ot_excess8_hours = ((@@regular_on_rest_ot_total.to_d - 8)%8).to_s.split('.').first
						   			@@regular_on_rest_ot_excess8_mins = "#{(((@@regular_on_rest_ot_total.to_d%8).to_s.split('.').last).to_d * 0.6).to_s.split('.').first}"
						   			@@regular_on_rest_ot_first8_days = 1
						   			@@regular_on_rest_ot_first8_mins = 0
						   			@@regular_on_rest_ot_first8_hours = 0
									else
										@@regular_on_rest_ot_first8_days = (@@regular_on_rest_ot_total.to_d/8).to_s.split('.').first
						   			@@regular_on_rest_ot_first8_mins = (@@regular_on_rest_ot_total.to_d%8).to_s.split('.').first
						   			@@regular_on_rest_ot_first8_hours = "#{(((@@regular_on_rest_ot_total.to_d%8).to_s.split('.').last).to_d * 0.6).to_s.split('.').first}"
								end
		



							end
						end
						employeedtr.serialize "#{@@dtr_peremployee_path}"
						

						summarydtr_ws.add_row [i+1,"#{emp.last_name},#{emp.first_name}",
				    					   "#{@@times_late}", "#{@@late_days}.#{@@late_hours}.#{@@late_mins}", "#{@@ut_days}.#{@@ut_hours}.#{@@ut_mins}",
				    					   "#{@@sl_balance_start_days}.#{@@sl_balance_start_hours}.0", "#{@@sl_days}.#{@@sl_hours}.0",
				    					   "#{@@vl_balance_start_days}.#{@@vl_balance_start_hours}.0", "#{@@vl_days}.#{@@vl_hours}.0",
				    					   "#{@@total_leave_late_ut_days}.#{@@total_leave_late_ut_hours}.#{@@total_leave_late_ut_mins}",
				    					   "#{@@reg_ot_days}.#{@@reg_ot_hours}.#{@@reg_ot_mins}", 
				    					   "#{@@rest_or_special_ot_first8_days}.#{@@rest_or_special_ot_first8_hours}.#{@@rest_or_special_ot_first8_mins}", ("#{@@rest_or_special_ot_excess8_days}.#{@@rest_or_special_ot_excess8_hours}.#{@@rest_or_special_ot_excess8_mins}" if @@rest_or_special_ot_total > 8), 
				    					   "#{@@special_on_rest_ot_first8_days}.#{@@special_on_rest_ot_first8_hours}.#{@@special_on_rest_ot_first8_mins}", ("#{@@special_on_rest_ot_excess8_days}.#{@@special_on_rest_ot_excess8_hours}.#{@@special_on_rest_ot_excess8_mins}" if @@special_on_rest_ot_total > 8), 
				    					   "#{@@regular_holiday_ot_first8_days}.#{@@regular_holiday_ot_first8_hours}.#{@@regular_holiday_ot_first8_mins}", ("#{@@regular_holiday_ot_excess8_days}.#{@@regular_holiday_ot_excess8_hours}.#{@@regular_holiday_ot_excess8_mins}" if @@regular_holiday_ot_total > 8),
				    					   "#{@@regular_on_rest_ot_first8_days}.#{@@regular_on_rest_ot_first8_hours}.#{@@regular_on_rest_ot_first8_mins}", ("#{@@regular_on_rest_ot_excess8_days}.#{@@regular_on_rest_ot_excess8_hours}.#{@@regular_on_rest_ot_excess8_mins}" if @@regular_on_rest_ot_total > 8),
				    					   "0", "#{@@total_ot_days}.#{@@total_ot_hours}.#{@@total_ot_mins}"], style: tabledata
					end
				end
			end
			summarydtr.serialize "#{@@dtr_summary_path}"
			zipfile.add('DTR_Summary.xlsx', @@dtr_summary_path)
			zipfile.add('Employee', Rails.root.join('public', 'reports', 'employee dtr'))
		}

		iEMS_path = Rails.root.join('public', 'uploads', 'iEMS.csv')
	  	biometrics_path = Rails.root.join('public', 'uploads','biometrics.csv')
	  	falco_path = Rails.root.join('public', 'uploads','falco.txt')

	# 	File.delete(biometrics_path) if File.exists?(biometrics_path)
	#  	File.delete(falco_path) if File.exists?(falco_path)
	#  	File.delete(iEMS_path) if File.exists?(iEMS_path)
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


	# def create_zip
	# 	# (date_start=nil, date_end=nil)
	# 	# if :date_start.nil? && :date_end.nil?
	# 	# 	token = File.open(Rails.root.join('public', 'uploads', 'iEMS.csv'), &:readline).split(',')
	# 	#   	@date_start = token[1].to_date
	# 	#   	@date_end = token[3].to_date
	# 	# else
	# 	#  	@date_start = :date_start
	# 	#  	@date_end = :date_end
	# 	# end
	# 	token = File.open(Rails.root.join('public', 'uploads', 'iEMS.csv'), &:readline).split(',')
	# 	  	@date_start = token[1].to_date
	# 	  	@date_end = token[3].to_date

	#   	@@filename = "DTR for #{@date_start} to #{@date_end}.zip"

	# 	Zip::File.open('reports.zip', Zip::File::CREATE) { |zipfile|

	# 		zipfile.get_output_stream("DTR Summary Sheet.xls") { |summary|
	# 			summary.puts(CSV.generate do |summarycsv| #CREATE DTR SUMMARY
	# 				summarycsv << ["iRipple, Inc."]
	# 				summarycsv << [" ", "DTR Summary Sheet for the period \n #{@date_start}, to #{@date_end}", "TARDINESS", "TARDINESS", "TARDINESS", "SL", "SL", "VL", "VL", "TOTAL DEDUCTION", "OT", "OT", "OT", "OT", "OT", "OT", "OT", "OT", "OT", "OT", "OT"]
	# 				summarycsv << ["NO.", 
	# 							   "NAME", 
	# 							   "FREQUENCY", 
	# 							   "NO. OF HOURS", 
	# 							   "UNDERTIME", 
	# 							   "CREDITS", 
	# 							   "BALANCE", 
	# 							   "CREDITS", 
	# 							   "BALANCE", 
	# 							   "(TARDINESS + \n LEAVE + \n UNDERTIME)", 
	# 							   "REGULAR DAY",
	# 							   "REST DAY OR \n SPECIAL PUBLIC HOLIDAY",
	# 							   "REST DAY OR \n SPECIAL PUBLIC HOLIDAY EXCESS 8 HRS",
	# 							   "SPECIAL PUBLIC HOLIDAY \n ON REST DAY",
	# 							   "SPECIAL PUBLIC HOLIDAY \n ON REST DAY EXCESS 8 HRS",
	# 							   "REGULAR HOLIDAY",
	# 							   "REGULAR HOLIDAY \n EXCESS 8 HRS",
	# 							   "REGULAR HOLIDAY ON REST DAY",
	# 							   "REGULAR HOLIDAY ON REST DAY \n EXCESS 8 HRS",
	# 							   "ALLOWANCE",
	# 							   "TOTAL"]
	
	# 			    Employee.find_by_sql("SELECT * FROM employees ORDER BY last_name").each_with_index do |emp, i|

	# 			    	next if emp.falco_id.nil? && emp.biometrics_id.nil?
	# 					zipfile.get_output_stream("Employees/#{emp.last_name}_#{emp.first_name}.xls") { |f| 
	# 						f.puts(to_csv(emp, @date_start, @date_end)) #CREATE XLS PER EMPLOYEE
	# 					}

	# 					summarycsv << [i+1, 
	# 								"#{emp.last_name},#{emp.first_name}", 
	# 								"#{@@times_late}", 
	# 								"#{@@late_days}.#{@@late_hours}.#{@@late_mins}",
	# 								"#{@@ut_days}.#{@@ut_hours}.#{@@ut_mins}",
	# 								"#{@@sl_days}.#{@@sl_hours}.0",
	# 								"#{@@sl_balance_start_days}.#{@@sl_balance_start_hours}.0",
	# 								"#{@@vl_days}.#{@@vl_hours}.0",
	# 								"#{@@vl_balance_start_days}.#{@@vl_balance_start_hours}.0",
	# 								"#{@@total_leave_late_ut_days}.#{@@total_leave_late_ut_hours}.#{@@total_leave_late_ut_mins}",
	# 								"#{@@reg_ot_days}.#{@@reg_ot_hours}.#{@@reg_ot_mins}",
	# 								"#{@@rest_or_special_ot_first8_days}.#{@@rest_or_special_ot_first8_hours}.#{@@rest_or_special_ot_first8_mins}",
	# 								("#{@@rest_or_special_ot_excess8_days}.#{@@rest_or_special_ot_excess8_hours}.#{@@rest_or_special_ot_excess8_mins}" if @@rest_or_special_ot_total > 8),
	# 								"#{@@special_on_rest_ot_first8_days}.#{@@special_on_rest_ot_first8_hours}.#{@@special_on_rest_ot_first8_mins}",
	# 								("#{@@special_on_rest_ot_excess8_days}.#{@@special_on_rest_ot_excess8_hours}.#{@@special_on_rest_ot_excess8_mins}" if @@special_on_rest_ot_total > 8),
	# 								"#{@@regular_holiday_ot_first8_days}.#{@@regular_holiday_ot_first8_hours}.#{@@regular_holiday_ot_first8_mins}",
	# 								("#{@@regular_holiday_ot_excess8_days}.#{@@regular_holiday_ot_excess8_hours}.#{@@regular_holiday_ot_excess8_mins}" if @@regular_holiday_ot_total > 8),
	# 								"#{@@regular_on_rest_ot_first8_days}.#{@@regular_on_rest_ot_first8_hours}.#{@@regular_on_rest_ot_first8_mins}",
	# 								("#{@@regular_on_rest_ot_excess8_days}.#{@@regular_on_rest_ot_excess8_hours}.#{@@regular_on_rest_ot_excess8_mins}" if @@regular_on_rest_ot_total > 8),
	# 								" ",
	# 								"#{@@total_ot_days}.#{@@total_ot_hours}.#{@@total_ot_mins}"]
	# 				end
	# 			end)
	# 		}
	# 	}

	# 	iEMS_path = Rails.root.join('public', 'uploads', 'iEMS.csv')
	#   	biometrics_path = Rails.root.join('public', 'uploads','biometrics.csv')
	#   	falco_path = Rails.root.join('public', 'uploads','falco.txt')

	# # 	File.delete(biometrics_path) if File.exists?(biometrics_path)
	# #  	File.delete(falco_path) if File.exists?(falco_path)
	# #  	File.delete(iEMS_path) if File.exists?(iEMS_path)
	# end

	# def to_csv(emp, date_start, date_end)
	# 	@@hours_late = 0
	# 	@@times_late = 0
	# 	@@hours_ot = 0
	# 	@@times_vl = 0
	# 	@@times_sl = 0
	# 	@@ut_total = 0
	# 	@@vl_balance_start = Request.where(employee_id: emp.id).first.vacation_leave_balance
	# 	@@sl_balance_start = Request.where(employee_id: emp.id).first.sick_leave_balance

	# 	@@vl_balance_start_days = @@vl_balance_start.to_s.split('.').first
	# 	@@vl_balance_start_hours = (((@@vl_balance_start.to_s.split('.').last).to_i)*0.8).to_i

	# 	@@sl_balance_start_days = @@sl_balance_start.to_s.split('.').first
	# 	@@sl_balance_start_hours = (((@@sl_balance_start.to_s.split('.').last).to_i)*0.8).to_i

	# 	@@reg_ot_total = 0
	# 	@@rest_or_special_ot_total = 0
	# 	@@special_on_rest_ot_total = 0
	# 	@@regular_holiday_ot_total = 0
	# 	@@regular_on_rest_ot_total = 0	

	# 	@date = date_start
	# 	@@cutoff_date = '2015-04-01'.to_date

	# 	CSV.generate do |csv|
	# 		csv << ["iRipple, Inc."]
	# 		csv << ["Name: #{emp.last_name}, #{emp.first_name}"]
	# 		csv << ["Department: #{emp.department}"]
	# 		csv << ["DATE", "DAY", "TIME IN", "TIME OUT", "UT DEPARTURE", "NO OF HRS LATE", "NO OF OT HOURS", "VL", "SL", "REMARKS"]
	# 		while @date <= date_end

	# 			# Request.find_by_sql("SELECT * FROM requests WHERE employee_id = '#{emp.id}' ORDER BY date").each do |req|
	# 			# Request.where(employee_id: emp.id).each do |req|
	# 			@attendance = Attendance.where(employee_id: emp.id, attendance_date: @date).first
	# 			@req = Request.where(employee_id: emp.id, date: @date).first

	# 			@@nohrs_ut = 0
	# 			#FOR UT COMPUTATION
	# 			if !@attendance.nil? && !@attendance.time_out.nil? 
	# 				if !@req.ut_time.nil?
	# 					if @attendance.time_out.to_time.strftime('%H:%M:%S') < @req.ut_time.to_time.strftime('%H:%M:%S')
	# 						@@numut = ((@req.ut_time.to_time.strftime('%H:%M:%S') - @attendance.time_out.to_time.strftime('%H:%M:%S'))/1.hour)
	# 						if @@numut > 1.25
	# 							@@nohrs_ut = 1.50
	# 						elsif @@numut > 1
	# 							@@nohrs_ut = 1.25
	# 						elsif @@numut > 0.75
	# 							@@nohrs_ut = 1.0
	# 						elsif @@numut > 0.50
	# 							@@nohrs_ut = 0.75
	# 						elsif @@numut > 0.25
	# 							@@nohrs_ut = 0.50
	# 						else 
	# 							@@nohrs_ut = 0.25
	# 						end
	# 						@@ut_total += @@nohrs_ut
	# 					end
	# 				else
	# 					if @attendance.time_out.to_time.strftime('%H:%M:%S').to_time > '16:30:00'.to_time
	# 						if @req.date.strftime('%A').to_s == "Friday"
	# 							if @attendance.time_out.to_time.strftime('%H:%M:%S').to_time < '17:30:00'.to_time
	# 								@@numut = (('17:30:00'.to_time - @attendance.time_out.to_time.strftime('%H:%M:%S').to_time)/1.hour)
	# 								if @@numut > 0.75
	# 									@@nohrs_ut = 1.0
	# 								elsif @@numut > 0.50
	# 									@@nohrs_ut = 0.75
	# 								elsif @@numut > 0.25
	# 									@@nohrs_ut = 0.50
	# 								else 
	# 									@@nohrs_ut = 0.25
	# 								end
	# 								@@ut_total += nohrs_ut
	# 							end
	# 						elsif @req.date.strftime('%A').to_s == "Monday" || @req.date.strftime('%A').to_s == "Tuesday" || @req.date.strftime('%A').to_s == "Wednesday" || @req.date.strftime('%A').to_s == "Thursday"
	# 							if @attendance.time_out.to_time.strftime('%H:%M:%S').to_time < '18:30:00'.to_time
	# 								@@numut = (('18:30:00'.to_time - @attendance.time_out.to_time.strftime('%H:%M:%S').to_time)/1.hour)
	# 								if @@numut > 1.75
	# 									@@nohrs_ut = 2.0
	# 								elsif @@numut > 1.5
	# 									@@nohrs_ut = 1.75
	# 								elsif @@numut > 1.25
	# 									@@nohrs_ut = 1.5
	# 								elsif @@numut > 1
	# 									@@nohrs_ut = 1.25
	# 								elsif @@numut > 0.75
	# 									@@nohrs_ut = 1.0
	# 								elsif @@numut > 0.50
	# 									@@nohrs_ut = 0.75
	# 								elsif @@numut > 0.25
	# 									@@nohrs_ut = 0.50
	# 								else 
	# 									@@nohrs_ut = 0.25
	# 								end
	# 								@@ut_total += @@nohrs_ut
	# 							end
	# 						end
	# 					else
	# 						@req.sick_leave = 0.5 #MARK THIS ROW RED
	# 					end
	# 				end
	# 			end

	# 			#FOR COMPUTING NUMBER OF HOURS LATE
	# 			@@nohrs_late = 0
	# 			if !@attendance.nil?
	# 				if @attendance.time_in.strftime('%H:%M:%S').to_time >= '10:00:00'.to_time
	# 					if @@cutoff_date >= date_start && @@cutoff_date <= date_end
	# 						if @date < @@cutoff_date
	# 							@req.sick_leave = 0.5 #MARK THIS ROW RED
	# 						end
	# 					end
	# 				elsif @attendance.time_in.strftime('%H:%M:%S').to_time > '08:30:00'.to_time
	# 					@@numlate = ((@attendance.time_in.strftime('%H:%M:%S').to_time - '08:30:00'.to_time)/1.hour)
	# 					if @@numlate > 0.75
	# 						@@nohrs_late = 1.0
	# 					elsif @@numlate > 0.50
	# 						@@nohrs_late = 0.75
	# 					elsif @@numlate > 0.25
	# 						@@nohrs_late = 0.50
	# 					else 
	# 						@@nohrs_late = 0.25
	# 					end
	# 					@@hours_late += @@nohrs_late
	# 					@@times_late += 1
	# 				end
	# 			end

	# 			#OT HOURS COMPUTATION
	# 			@@present_othours = 0
	# 			if !@req.nil?
	# 				if !@req.regular_ot.nil?
	# 					@@present_othours = @req.regular_ot.to_d
	# 					@@reg_ot_total += @req.regular_ot.to_d
	# 				elsif !@req.rest_or_special_ot.nil?
	# 					@@present_othours = @req.rest_or_special_ot.to_d
	# 					@@rest_or_special_ot_total += @req.rest_or_special_ot.to_d
	# 				elsif !@req.special_on_rest_ot.nil?
	# 					@@present_othours = @req.special_on_rest_ot.to_d
	# 					@@special_on_rest_ot_total += @req.special_on_rest_ot.to_d
	# 				elsif !@req.regular_holiday_ot.nil?
	# 					@@present_othours = @req.regular_holiday_ot.to_d
	# 					@@regular_holiday_ot_total += @req.regular_holiday_ot.to_d
	# 				elsif !@req.regular_on_rest_ot.nil?
	# 					@@present_othours = @req.regular_on_rest_ot.to_d
	# 					@@regular_on_rest_ot_total += @req.regular_on_rest_ot.to_d
	# 				end
					
	# 				if @@cutoff_date >= date_start && @@cutoff_date <= date_end
	# 					if @date < @@cutoff_date
	# 						@@times_vl += @req.vacation_leave.to_d if !@req.vacation_leave.nil?
	# 						@@times_sl += @req.sick_leave.to_d if !@req.sick_leave.nil?
	# 					end
	# 				else
	# 					@@times_vl += @req.vacation_leave.to_d if !@req.vacation_leave.nil?
	# 					@@times_sl += @req.sick_leave.to_d if !@req.sick_leave.nil?
	# 				end
	# 			end
	# 			@@hours_ot += @@present_othours

	# 		    csv << [@req.date.strftime('%m-%d-%Y'),
	# 		    	@req.date.strftime('%A'), 
	# 		    	(@attendance.time_in.to_time.strftime('%H:%M:%S') if !@attendance.nil? && !@attendance.time_in.nil?), 
	# 		    	(@attendance.time_out.to_time.strftime('%H:%M:%S') if !@attendance.nil? && !@attendance.time_out.nil?), 
	# 		    	(@@nohrs_ut if @@nohrs_ut != 0),
	# 		    	(@@nohrs_late if @@nohrs_late != 0),
	# 		    	@@present_othours,
	# 		    	@req.vacation_leave,
	# 		    	@req.sick_leave,
	# 		    	@req.remarks]

	#         	@date += 1.day #FOR USING DATE START AND DATE END AS BASIS FOR LOOP
 #        	end

	#         csv << [" ", " ", " ", " ", "NUMBER OF TIMES TARDY", @@times_late]
	#         csv << [" ", " ",  " ", " ", "TOTAL TARDINESS", @@hours_late]
	#         csv << [" ", " ", " ", " ", " ", "TOTAL OT HOURS", @@hours_ot]
	#         csv << [" ", " ", " ", " ", " ", " ", "TOTAL LEAVES ACCUMULATED", @@times_vl.to_f, @@times_sl.to_f]
	#         csv << [" "]

	#         @@total_ot_days = (@@hours_ot/8).to_s.split('.').first
	#         @@total_ot_hours = (@@hours_ot%8).to_s.split('.').first
 #       		@@total_ot_mins = "#{(((@@hours_ot%8).to_s.split('.').last).to_d * 0.6).to_s.split('.').first}"

	#        	@@late_days = (@@hours_late/8).to_s.split('.').first
	#        	@@late_hours = (@@hours_late%8).to_s.split('.').first
 #       		@@late_mins = "#{(((@@hours_late%8).to_s.split('.').last).to_d * 0.6).to_s.split('.').first}"

 #       		@@vl_days = @@times_vl.to_s.split('.').first
 #       		@@vl_hours = ((@@times_vl.to_s.split('.').last).to_d * 0.8).to_s.split('.').first

 #       		@@sl_days = @@times_sl.to_s.split('.').first
 #       		@@sl_hours = ((@@times_sl.to_s.split('.').last).to_d * 0.8).to_s.split('.').first

 #       		@@vl_total = 0
 #       		@@sl_total = 0

 #       		if @@times_vl.to_d > @@vl_balance_start.to_d
 #       			@@vl_total = @@times_vl.to_d - @@vl_balance_start.to_d
 #       		end

 #       		if @@times_sl.to_d > @@sl_balance_start.to_d
 #       			@@sl_total = @@times_sl.to_d - @@sl_balance_start.to_d
 #       		end

 #       		@@total_leave_late = @@vl_total + @@sl_total + @@hours_late

 #       		@@total_leave_late_days = (@@total_leave_late/8).to_s.split('.').first
 #       		@@total_leave_late_hours = (@@total_leave_late%8).to_s.split('.').first
 #       		@@total_leave_late_mins = "#{(((@@total_leave_late%8).to_s.split('.').last).to_d * 0.6).to_s.split('.').first}"

	# 		@@ut_days = (@@ut_total/8).to_s.split('.').first
	#         @@ut_hours = (@@ut_total%8).to_s.split('.').first
 #       		@@ut_mins = "#{(((@@ut_total%8).to_s.split('.').last).to_d * 0.6).to_s.split('.').first}"


 #       		@@total_leave_late_ut = @@total_leave_late + @@ut_total

 #       		@@total_leave_late_ut_days = (@@total_leave_late_ut/8).to_s.split('.').first
 #       		@@total_leave_late_ut_hours = (@@total_leave_late_ut%8).to_s.split('.').first
 #       		@@total_leave_late_ut_mins = "#{(((@@total_leave_late_ut%8).to_s.split('.').last).to_d * 0.6).to_s.split('.').first}"

	#         csv << ["ACCUMULATED OT", "#{@@total_ot_days}.#{@@total_ot_hours}.#{@@total_ot_mins}"]
	#         csv << ["LATES", "#{@@late_days}.#{@@late_hours}.#{@@late_mins}"]
	#         csv << ["ACCUMULATED VL", "#{@@vl_days}.#{@@vl_hours}.0"]
	#         csv << ["ACCUMULATED SL", "#{@@sl_days}.#{@@sl_hours}.0"]
	#         csv << ["VL BALANCE", "#{@@vl_balance_start_days}.#{@@vl_balance_start_hours}.0"]
	#         csv << ["SL BALANCE", "#{@@sl_balance_start_days}.#{@@sl_balance_start_hours}.0"]
	#         csv << ["TOTAL", "#{@@total_leave_late_days}.#{@@total_leave_late_hours}.#{@@total_leave_late_mins}"]
	#         csv << [@@vl_total, @@sl_total, @@hours_late, @@ut_total]

	# 		@@reg_ot_days = (@@reg_ot_total/8).to_s.split('.').first
	#         @@reg_ot_hours = (@@reg_ot_total%8).to_s.split('.').first
 #       		@@reg_ot_mins = "#{(((@@reg_ot_total%8).to_s.split('.').last).to_d * 0.6).to_s.split('.').first}"

 #       		if @@rest_or_special_ot_total.to_d > 8
 #       			@@rest_or_special_ot_excess8_days = ((@@rest_or_special_ot_total.to_d - 8)/8).to_s.split('.').first
 #       			@@rest_or_special_ot_excess8_hours = ((@@rest_or_special_ot_total.to_d - 8)%8).to_s.split('.').first
 #       			@@rest_or_special_ot_excess8_mins = "#{(((@@rest_or_special_ot_total.to_d%8).to_s.split('.').last).to_d * 0.6).to_s.split('.').first}"
 #       			@@rest_or_special_ot_first8_days = 1
 #       			@@rest_or_special_ot_first8_mins = 0
 #       			@@rest_or_special_ot_first8_hours = 0
 #   			else
 #   				@@rest_or_special_ot_first8_days = (@@rest_or_special_ot_total.to_d/8).to_s.split('.').first
 #       			@@rest_or_special_ot_first8_mins = (@@rest_or_special_ot_total.to_d%8).to_s.split('.').first
 #       			@@rest_or_special_ot_first8_hours = "#{(((@@rest_or_special_ot_total.to_d%8).to_s.split('.').last).to_d * 0.6).to_s.split('.').first}"
 #   			end

 #   			if @@special_on_rest_ot_total.to_d > 8
 #       			@@special_on_rest_ot_excess8_days = ((@@special_on_rest_ot_total.to_d - 8)/8).to_s.split('.').first
 #       			@@special_on_rest_ot_excess8_hours = ((@@special_on_rest_ot_total.to_d - 8)%8).to_s.split('.').first
 #       			@@special_on_rest_ot_excess8_mins = "#{(((@@special_on_rest_ot_total.to_d%8).to_s.split('.').last).to_d * 0.6).to_s.split('.').first}"
 #       			@@special_on_rest_ot_first8_days = 1
 #       			@@special_on_rest_ot_first8_mins = 0
 #       			@@special_on_rest_ot_first8_hours = 0
 #   			else
 #   				@@special_on_rest_ot_first8_days = (@@special_on_rest_ot_total/8).to_s.split('.').first
 #       			@@special_on_rest_ot_first8_mins = (@@special_on_rest_ot_total%8).to_s.split('.').first
 #       			@@special_on_rest_ot_first8_hours = "#{(((@@special_on_rest_ot_total.to_d%8).to_s.split('.').last).to_d * 0.6).to_s.split('.').first}"
 #   			end

 #   			if @@regular_holiday_ot_total.to_d > 8
 #       			@@regular_holiday_ot_excess8_days = ((@@regular_holiday_ot_total.to_d - 8)/8).to_s.split('.').first
 #       			@@regular_holiday_ot_excess8_hours = ((@@regular_holiday_ot_total.to_d - 8)%8).to_s.split('.').first
 #       			@@regular_holiday_ot_excess8_mins = "#{(((@@regular_holiday_ot_total.to_d%8).to_s.split('.').last).to_d * 0.6).to_s.split('.').first}"
 #       			@@regular_holiday_ot_first8_days = 1
 #       			@@regular_holiday_ot_first8_mins = 0
 #       			@@regular_holiday_ot_first8_hours = 0
 #   			else
 #   				@@regular_holiday_ot_first8_days = (@@regular_holiday_ot_total.to_d/8).to_s.split('.').first
 #       			@@regular_holiday_ot_first8_mins = (@@regular_holiday_ot_total.to_d%8).to_s.split('.').first
 #       			@@regular_holiday_ot_first8_hours = "#{(((@@regular_holiday_ot_total.to_d%8).to_s.split('.').last).to_d * 0.6).to_s.split('.').first}"
 #   			end

 #   			if @@regular_on_rest_ot_total.to_d > 8
 #       			@@regular_on_rest_ot_excess8_days = ((@@regular_on_rest_ot_total.to_d - 8)/8).to_s.split('.').first
 #       			@@regular_on_rest_ot_excess8_hours = ((@@regular_on_rest_ot_total.to_d - 8)%8).to_s.split('.').first
 #       			@@regular_on_rest_ot_excess8_mins = "#{(((@@regular_on_rest_ot_total.to_d%8).to_s.split('.').last).to_d * 0.6).to_s.split('.').first}"
 #       			@@regular_on_rest_ot_first8_days = 1
 #       			@@regular_on_rest_ot_first8_mins = 0
 #       			@@regular_on_rest_ot_first8_hours = 0
 #   			else
 #   				@@regular_on_rest_ot_first8_days = (@@regular_on_rest_ot_total.to_d/8).to_s.split('.').first
 #       			@@regular_on_rest_ot_first8_mins = (@@regular_on_rest_ot_total.to_d%8).to_s.split('.').first
 #       			@@regular_on_rest_ot_first8_hours = "#{(((@@regular_on_rest_ot_total.to_d%8).to_s.split('.').last).to_d * 0.6).to_s.split('.').first}"
 #   			end
	# 	end
	# end