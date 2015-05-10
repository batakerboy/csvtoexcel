include FileUtils
require 'csv'
require 'pathname'
require 'rubygems'
require 'zip'
require 'axlsx'

class Report < ActiveRecord::Base
	@@cut_off_date = '2015-04-01'

	def self.save(biometrics = nil, falco = nil, iEMS = nil)
		# dir = File.dirname("#{Rails.root}/public/uploads/biometrics.csv")
 	 	# FileUtils.mkdir_p(dir) unless File.directory?(dir)
		# directory = 'public/uploads'
		directory = Rails.root.join('public', 'uploads')
		Dir.mkdir(directory) unless File.exists?(directory)
		
		unless biometrics.nil?
			name = biometrics['report'].original_filename
			path = File.join(directory, 'biometrics.csv')
			File.open(path, "wb") { |f| f.write(biometrics['report'].read)}
		end

		unless falco.nil?
			name = falco['report'].original_filename
			path = File.join(directory, 'falco.txt')
			File.open(path, 'wb') { |f| f.write(falco['report'].read)}
		end

		unless iEMS.nil?
			name = iEMS['report'].original_filename
			path = File.join(directory, 'iEMS.csv')
			File.open(path, 'wb') { |f| f.write(iEMS['report'].read)}
		end
	end

	def create_zip
	 	report_zip_path = Rails.root.join('public', 'reports', 'reports.zip')
		Dir.mkdir(report_zip_path) unless File.exists?(report_zip_path)
		
		Zip::File.open(report_zip_path, Zip::File::CREATE) { |zipfile|
			# dtr_summary_filename = "DTR Summary for #{self.date_start} - #{self.date_end} cut-off"
			dtr_summary_filename = "DTRSUMMARY.xlsx"
			dtr_summary_path = Rails.root.join('public', 'reports', dtr_summary_filename)

			summarydtr = Axlsx::Package.new
	 
			# Required for use with numbers
			summarydtr.use_shared_strings = true
			
			summarydtr.workbook do |summarydtr_wb|
			# define your regular styles
				styles = summarydtr_wb.styles
				title = styles.add_style sz: 15, b: true, u: true
				headers = styles.add_style sz: 11, b: true, border: {:style => :thin, :color => '00000000', :edges => [:top, :left, :right, :bottom] }, alignment: { :horizontal => :center, :vertical => :center, :wrap_text => true}
				tabledata = styles.add_style sz: 11, border: {:style => :thin, :color => '00000000', :edges => [:top, :left, :right, :bottom] }, alignment: { :horizontal => :center, :vertical => :center, :wrap_text => true}
				summaryrownum = 0
				summarydtr_wb.add_worksheet(name: 'DTR SUMMARY') do  |summarydtr_ws|
					summarydtr_ws.add_row ['iRipple, Inc.'], style: title
					summaryrownum += 1
				    summarydtr_ws.add_row ["DTR Summary Sheet for the period #{self.date_start.strftime('%B %d, %Y')} to #{self.date_end.strftime('%B %d, %Y')}", " ", " ", 
				    					   "TARDINESS", " ", " ", 
				    					   "SL", " ", 
				    					   "VL", " ", 
				    					   "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "AA", "AB", "AC", "AD", "AE", "AF", "AG", " AH", "AI", "AJ", "AK", "AL", " AM", "AN", "AO", "AP", "AQ", "AR", "AS", 
				    					   "TOTAL DEDUCTION",
				    					   "OT", " ", " ", " ", " ", " ", " ", " ", " ", " ",
				    					   " ", " ", " ", " ", " ", " ", " ", " ", " ", " ",
				    					   " ", " ", " ", " ", " ", " ", " ", " ", " ", " ",
				    					   " ", " ", " ", " ", " ", " ", " ", " ", " ", " ",
				    					   " ", " ", " ", " ", " ", " ", " ", " ", " ", " ",
				    					   " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " "], style: headers
				    					   
				    summaryrownum += 1
				    summarydtr_ws.add_row ["NO.","NAME", "DEPARTMENT", 
				    					   "FREQUENCY", "NO. OF HOURS", "UNDERTIME", 
				    					   "CREDITS", "BALANCE", "CREDITS", "BALANCE", 
				    					   "1st column", "UT", "vl credits", "sl credits", "vl balance", "sl balance", " ", 
				    					   "2nd column", " ", "accum vl", "accum sl", "vl balance", "sl balance", 
				    					   "3rd column", " ", "accum vl", "accum sl", "vl balance", "sl balance", " ", 
				    					   "4th column", "UT", "accum vl", "accum sl", "vl balance", "sl balance", " ", 
				    					   "5th column", "UT", "accum vl", "accum sl", "vl balance", "sl balance", " ", "total", 
				    					   "TARDINESS + LEAVE + UNDERTIME", 
				    					   "REGULAR DAY",  
				    					   "REST DAY OR SPECIAL PUBLIC HOLIDAY", "REST DAY OR SPECIAL PUBLIC HOLIDAY EXCESS 8 HOURS",  
				    					   "SPECIAL PUBLIC HOLIDAY ON REST DAY", "SPECIAL PUBLIC HOLIDAY ON REST DAY EXCESS 8 HOURS",  
				    					   "REGULAR HOLIDAY", "REGULAR HOLIDAY EXCESS 8 HOURS", 
				    					   "REGULAR HOLIDAY ON REST DAY", "REGULAY HOLIDAY ON REST DAY EXCESS 8 HOURS", 
				    					   " ", " ", " ", " ", " ", " ", " ", " ", " ", " ",
				    					   " ", " ", " ", " ", " ", " ", " ", " ", " ", " ",
				    					   " ", " ", " ", " ", " ", " ", " ", " ", " ", " ",
				    					   " ", " ", " ", " ", " ", " ", " ", " ", " ", " ",
				    					   " ", " ", " ", " ", " ", " ", " ", " ", " ", " ",
				    					   "ALLOWANCE", "TOTAL"], style: headers
				    summaryrownum += 1
				    # Otherwise you can specify a style for each column.
				    # summarydtr_ws.add_row ['Q1-2011', '26740000000', '=B5/SUM(B4:B7)'], style: [pascal, money_pascal, percent_pascal]

				    # You can merge cells!
				    summarydtr_ws.merge_cells 'A1:DC1'
				    summarydtr_ws.merge_cells 'A2:C2'
				    summarydtr_ws.merge_cells 'D2:F2'
				    summarydtr_ws.merge_cells 'G2:H2'
				    summarydtr_ws.merge_cells 'I2:J2'
				    summarydtr_ws.merge_cells 'AU2:DC2'


				    # Employee.find_by_sql("SELECT * FROM employees ORDER BY last_name").each_with_index do |emp, i|
				    Employee.all.order(last_name: :asc).each_with_index do |emp, i|
				    	employeedtr_filename = "#{emp.last_name},#{emp.first_name}.xlsx"
				    	dtr_peremployee_path = Rails.root.join('public', 'reports', 'employee dtr', employeedtr_filename)

						File.delete(dtr_peremployee_path) if File.exists?(dtr_peremployee_path)

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


							employeedtr_wb.add_worksheet(name: 'EMPLOYEE DTR') do  |employeedtr_ws|
								employeedtr_ws.add_row ['iRipple, Inc.'], style: title
								employeedtr_ws.add_row ["Name: #{emp.last_name}, #{emp.first_name}"], style: title
								employeedtr_ws.add_row ["Department: #{emp.department}"], style: title
				   				employeedtr_ws.add_row ["DATE", "DAY", "TIME IN", "TIME OUT", "APPROVED UNDERTIME", "NO OF HOURS LATE",  "NO OF OVERTIME HOURS",  "VACATION LEAVE",  "SICK LEAVE",  "REMARKS"], style: headers
	    						employeedtr_ws.merge_cells 'A1:J1'
				    			employeedtr_ws.merge_cells 'A2:J2'
				    			employeedtr_ws.merge_cells 'A3:J3'
								
								date = self.date_start
								rownum = 5
								@@days_over_cutoffdate = 0
								while date <= self.date_end
									employeedtr_ws.add_row [date.strftime('%m-%d-%Y'),
														    date.strftime('%A'),
														    emp.time_in(date),
														    emp.time_out(date), 
														    (emp.ut_time(date).to_time.strftime('%H:%M:%S') unless emp.ut_time(date).to_time.strftime('%H:%M:%S') == '00:00:00'),
														    (emp.no_of_hours_late(date) if emp.no_of_hours_late(date) != 0),
														    emp.ot_for_the_day(date),
														    emp.vacation_leave(date),
														    emp.sick_leave(date),
														    emp.remarks(date)], style: tabledata

									rownum += 1
						        	date += 1.day #FOR USING DATE START AND DATE END AS BASIS FOR LOOP
						        	if @@cut_off_date.to_date.mon >= self.date_start.to_date.mon && @@cut_off_date.to_date.mon <= self.date_end.to_date.mon
						        		puts "====================================================================="
						        		puts "====================================================================="
						        		puts "====================================================================="
						        		if date >= @@cut_off_date.to_date
						        			@@days_over_cutoffdate += 1
						        		end
						        	end
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
						    	if @@cut_off_date.to_date.mon >= self.date_start.to_date.mon && @@cut_off_date.to_date.mon <= self.date_end.to_date.mon
					    			employeedtr_ws.add_row ["TOTAL LEAVES ACCUMULATED", "@@cut_off_date.to_date.mon >= self.date_start.to_date.mon && @@cut_off_date.to_date.mon <= self.date_end.to_date.mon", " ", " ", " ", " ", " ","=SUM(H5:H#{rownum-(4+@@days_over_cutoffdate)})", "=SUM(I5:I#{rownum-(4+@@days_over_cutoffdate)})", " "], style: tabledata
					    		else
					    			employeedtr_ws.add_row ["TOTAL LEAVES ACCUMULATED", " ", " ", " ", " ", " ", " ","=SUM(H5:H#{rownum-4})", "=SUM(I5:I#{rownum-4})", " "], style: tabledata
						    	end
						    	employeedtr_ws.merge_cells "A#{rownum}:G#{rownum}"
						    	rownum += 1

						    	employeedtr_ws.add_row 
						    	rownum += 1

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
						    	employeedtr_ws.add_row ["VL BALANCE", "#{emp.vacation_leave_balance_to_string(self.date_start)}", " ", " ", " ", " ", " ", " ", " ", " ", 
						    							"=INT(LEFT(B#{rownum+1},1))", 
						   							    "=RIGHT(B#{rownum+1},LEN(B#{rownum+1})-2)", 
						   							    "=INT(LEFT(L#{rownum},1))", 
						   							    "=RIGHT(L#{rownum},LEN(L#{rownum})-2)+0", 
						   							    "=K#{rownum}*8*60+M#{rownum}*60+N#{rownum}"], style: tabledata
						    	rownum += 1
						    	employeedtr_ws.add_row ["SL BALANCE", "#{emp.sick_leave_balance_to_string(self.date_start)}", " ", " ", " ", " ", " ", " ", " ", " ", 
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



							end
						end

						employeedtr.serialize "#{dtr_peremployee_path}"	
					
						summarydtr_ws.add_row [i+1,"#{emp.last_name},#{emp.first_name}", "emp.department", # A B C
				    					   	"#{emp.number_of_times_late(self.date_start, self.date_end)}", # D
			    					   		"#{emp.total_late_to_string(self.date_start, self.date_end)}", # E
				    					    "#{emp.total_undertime_to_string(self.date_start, self.date_end)}", # F
				    					    "#{emp.total_sl_to_string(self.date_start, self.date_end, @@cut_off_date)}", "#{emp.sick_leave_balance_to_string(self.date_start)}", # G H
				    					    "#{emp.total_vl_to_string(self.date_start, self.date_end, @@cut_off_date)}", "#{emp.vacation_leave_balance_to_string(self.date_start)}", # I J
				    					    "=INT(LEFT(E#{summaryrownum+1},1))", # K
				    					    "=INT(LEFT(F#{summaryrownum+1},1))", # L
				    					    "=INT(LEFT(I#{summaryrownum+1},1))", # M
				    					    "=INT(LEFT(G#{summaryrownum+1},1))", # N
				    					    "=INT(LEFT(J#{summaryrownum+1},1))", # O
				    					    "=INT(LEFT(H#{summaryrownum+1},1))", # P
				    					    "=K#{summaryrownum+1}+L#{summaryrownum+1}+IF(M#{summaryrownum+1}>M#{summaryrownum+1},M#{summaryrownum+1}-O#{summaryrownum+1},0)+IF(N#{summaryrownum+1}>P#{summaryrownum+1},N#{summaryrownum+1}-P#{summaryrownum+1},0)", # Q
				    					    "=RIGHT(E#{summaryrownum+1},LEN(E#{summaryrownum+1})-2)", # R
				    					    "=RIGHT(F#{summaryrownum+1},LEN(F#{summaryrownum+1})-2)", # S
				    					    "=RIGHT(I#{summaryrownum+1},LEN(I#{summaryrownum+1})-2)", # T
				    					    "=RIGHT(G#{summaryrownum+1},LEN(G#{summaryrownum+1})-2)", # U
				    					    "=RIGHT(J#{summaryrownum+1},LEN(J#{summaryrownum+1})-2)", # V
				    					    "=RIGHT(H#{summaryrownum+1},LEN(H#{summaryrownum+1})-2)", # W
				    					    "=INT(LEFT(R#{summaryrownum+1},1))", # X
				    					    "=INT(LEFT(S#{summaryrownum+1},1))", # Y
				    					    "=INT(LEFT(T#{summaryrownum+1},1))", # Z
				    					    "=INT(LEFT(U#{summaryrownum+1},1))", # AA
				    					    "=INT(LEFT(V#{summaryrownum+1},1))", # AB
				    					    "=INT(LEFT(W#{summaryrownum+1},1))", # AC
				    					    "=R#{summaryrownum+1}+S#{summaryrownum+1}+IF(T#{summaryrownum+1}>V#{summaryrownum+1},T#{summaryrownum+1}-V#{summaryrownum+1},0)+IF(U#{summaryrownum+1}>W#{summaryrownum+1},U#{summaryrownum+1}-W#{summaryrownum+1},0)", # AD
				    					    "=RIGHT(R#{summaryrownum+1},LEN(R#{summaryrownum+1})-2)+0", # AE
				    					    "=RIGHT(S#{summaryrownum+1},LEN(S#{summaryrownum+1})-2)+0", # AF
				    					    "=RIGHT(T#{summaryrownum+1},LEN(T#{summaryrownum+1})-2)+0", # AG
				    					    "=RIGHT(U#{summaryrownum+1},LEN(U#{summaryrownum+1})-2)+0", # AH
				    					    "=RIGHT(V#{summaryrownum+1},LEN(V#{summaryrownum+1})-2)+0", # AI
				    					    "=RIGHT(W#{summaryrownum+1},LEN(W#{summaryrownum+1})-2)+0", # AJ
				    					    "=AE#{summaryrownum+1}+IF(AG#{summaryrownum+1}>AI#{summaryrownum+1},AG#{summaryrownum+1}-AI#{summaryrownum+1},0)+IF(AH#{summaryrownum+1}>AJ#{summaryrownum+1},AH#{summaryrownum+1}-AJ#{summaryrownum+1},0)", # AK
				    					    "=K#{summaryrownum+1}*8*60+X#{summaryrownum+1}*60+AE#{summaryrownum+1}", # AL
				    					    "=L#{summaryrownum+1}*8*60+Y#{summaryrownum+1}*60+AF#{summaryrownum+1}", # AM
				    					    "=M#{summaryrownum+1}*8*60+Z#{summaryrownum+1}*60+AG#{summaryrownum+1}", # AN
				    					    "=N#{summaryrownum+1}*8*60+AA#{summaryrownum+1}*60+AH#{summaryrownum+1}", # AO
				    					    "=O#{summaryrownum+1}*8*60+AB#{summaryrownum+1}*60+AI#{summaryrownum+1}", # AP
				    					    "=P#{summaryrownum+1}*8*60+AC#{summaryrownum+1}*60+AJ#{summaryrownum+1}", # AQ
				    					    "=AL#{summaryrownum+1}+AM#{summaryrownum+1}+IF(AN#{summaryrownum+1}>AP#{summaryrownum+1},AN#{summaryrownum+1}-AP#{summaryrownum+1},0)+IF(AO#{summaryrownum+1}>AQ#{summaryrownum+1},AO#{summaryrownum+1}-AQ#{summaryrownum+1},0)", # AR
				    					    "=AR#{summaryrownum+1}/60", # AS
				    					    "=FLOOR(AS#{summaryrownum+1}/8,1,1)&"<<'"."'<<"&FLOOR(MOD(AS#{summaryrownum+1},8),1,1)&"<<'"."'<<"&(MOD(AS#{summaryrownum+1},8)-FLOOR(MOD(AS#{summaryrownum+1},8),1,1))*60", # AT
				    					    "#{emp.total_regular_ot_to_string(self.date_start, self.date_end)}",
				    					    "#{emp.total_rest_or_special_ot_to_string_first_8(self.date_start, self.date_end)}", "#{emp.total_rest_or_special_ot_to_string_excess(self.date_start, self.date_end)}", 
				    					    "#{emp.total_special_on_rest_ot_to_string_first_8(self.date_start, self.date_end)}", "#{emp.total_special_on_rest_ot_to_string_excess(self.date_start, self.date_end)}", 
				    					    "#{emp.total_regular_holiday_ot_to_string_first_8(self.date_start, self.date_end)}", "#{emp.total_regular_holiday_ot_to_string_excess(self.date_start, self.date_end)}",
				    					    "#{emp.total_regular_on_rest_ot_to_string_first_8(self.date_start, self.date_end)}", "#{emp.total_regular_on_rest_ot_to_string_excess(self.date_start, self.date_end)}",
				    					    "=INT(LEFT(AU#{summaryrownum+1},1))", "=INT(LEFT(AV#{summaryrownum+1},1))", "=INT(LEFT(AW#{summaryrownum+1},1))", "=INT(LEFT(AX#{summaryrownum+1},1))", "=INT(LEFT(AY#{summaryrownum+1},1))", "=INT(LEFT(AZ#{summaryrownum+1},1))", "=INT(LEFT(BA#{summaryrownum+1},1))", "=INT(LEFT(BB#{summaryrownum+1},1))", "=INT(LEFT(BC#{summaryrownum+1},1))", "=SUM(BD#{summaryrownum+1}:BL#{summaryrownum+1})",
				    					    "=RIGHT(AU#{summaryrownum+1},LEN(AU#{summaryrownum+1})-2)", "=RIGHT(AV#{summaryrownum+1},LEN(AV#{summaryrownum+1})-2)", "=RIGHT(AW#{summaryrownum+1},LEN(AW#{summaryrownum+1})-2)", "=RIGHT(AX#{summaryrownum+1},LEN(AX#{summaryrownum+1})-2)", "=RIGHT(AY#{summaryrownum+1},LEN(AY#{summaryrownum+1})-2)", "=RIGHT(AZ#{summaryrownum+1},LEN(AZ#{summaryrownum+1})-2)", "=RIGHT(BA#{summaryrownum+1},LEN(BA#{summaryrownum+1})-2)", "=RIGHT(BB#{summaryrownum+1},LEN(BB#{summaryrownum+1})-2)", "=RIGHT(BC#{summaryrownum+1},LEN(BC#{summaryrownum+1})-2)",
				    					    "=INT(LEFT(BN#{summaryrownum+1},1))", "=INT(LEFT(BO#{summaryrownum+1},1))", "=INT(LEFT(BP#{summaryrownum+1},1))", "=INT(LEFT(BQ#{summaryrownum+1},1))", "=INT(LEFT(BR#{summaryrownum+1},1))", "=INT(LEFT(BS#{summaryrownum+1},1))", "=INT(LEFT(BT#{summaryrownum+1},1))", "=INT(LEFT(BU#{summaryrownum+1},1))", "=INT(LEFT(BV#{summaryrownum+1},1))", "=SUM(BW#{summaryrownum+1}:CE#{summaryrownum+1})",
				    					    "=RIGHT(BN#{summaryrownum+1},LEN(BN#{summaryrownum+1})-2)+0", "=RIGHT(BO#{summaryrownum+1},LEN(BO#{summaryrownum+1})-2)+0", "=RIGHT(BP#{summaryrownum+1},LEN(BP#{summaryrownum+1})-2)+0", "=RIGHT(BQ#{summaryrownum+1},LEN(BQ#{summaryrownum+1})-2)+0", "=RIGHT(BR#{summaryrownum+1},LEN(BR#{summaryrownum+1})-2)+0", "=RIGHT(BS#{summaryrownum+1},LEN(BS#{summaryrownum+1})-2)+0", "=RIGHT(BT#{summaryrownum+1},LEN(BT#{summaryrownum+1})-2)+0", "=RIGHT(BU#{summaryrownum+1},LEN(BU#{summaryrownum+1})-2)+0", "=RIGHT(BV#{summaryrownum+1},LEN(BV#{summaryrownum+1})-2)+0", "=SUM(CG#{summaryrownum+1}:CO#{summaryrownum+1})",
				    					    "=BD#{summaryrownum+1}*8*60+BW#{summaryrownum+1}*60+CG#{summaryrownum+1}", "=BE#{summaryrownum+1}*8*60+BX#{summaryrownum+1}*60+CH#{summaryrownum+1}", "=BF#{summaryrownum+1}*8*60+BY#{summaryrownum+1}*60+CI#{summaryrownum+1}", "=BG#{summaryrownum+1}*8*60+BZ#{summaryrownum+1}*60+CJ#{summaryrownum+1}", "=BH#{summaryrownum+1}*8*60+CA#{summaryrownum+1}*60+CK#{summaryrownum+1}", "=BI#{summaryrownum+1}*8*60+CB#{summaryrownum+1}*60+CL#{summaryrownum+1}", "=BJ#{summaryrownum+1}*8*60+CC#{summaryrownum+1}*60+CM#{summaryrownum+1}", "=BK#{summaryrownum+1}*8*60+CD#{summaryrownum+1}*60+CN#{summaryrownum+1}", "=BL#{summaryrownum+1}*8*60+CE#{summaryrownum+1}*60+CO#{summaryrownum+1}", "=SUM(CQ#{summaryrownum+1}:CY#{summaryrownum+1})",
				    					    "=CZ#{summaryrownum+1}/60",
				    					    "0", "=FLOOR(DA#{summaryrownum+1}/8,1,1)&"<<'"."'<<"&FLOOR(MOD(DA#{summaryrownum+1},8),1,1)&"<<'"."'<<"&(MOD(DA#{summaryrownum+1},8)-FLOOR(MOD(DA#{summaryrownum+1},8),1,1))*60"], style: tabledata
						
						summaryrownum += 1
						summarydtr_ws.column_info[2].hidden = true
						i = 10
						while i <= 44
							summarydtr_ws.column_info[i].hidden = true
							i += 1
				        end
				        i = 55
				        while i <= 104
				        	summarydtr_ws.column_info[i].hidden = true
				        	i += 1
				        end
						
						zipfile.add("Employee/#{employeedtr_filename}", Rails.root.join('public', 'reports', 'employee dtr', employeedtr_filename))
					end
				end
			end
			summarydtr.serialize "#{dtr_summary_path}"
			zipfile.add('DTR_Summary.xlsx', dtr_summary_path)

		}
	end
end