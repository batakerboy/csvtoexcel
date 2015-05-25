include FileUtils
require 'csv'
require 'pathname'
require 'rubygems'
require 'zip'
require 'axlsx'
@@report = []
@@report << :panes
class Report < ActiveRecord::Base
	after_save :assign_name
	@@cut_off_date = '2015-04-01'

	def assign_name
		Report.update(self.id, name: "DTR-#{self.id} for #{self.date_start.strftime('%B %e, %Y')} to #{self.date_end.strftime('%B %e, %Y')}.zip") if self.name.nil?
	end

	def self.save(biometrics = nil, falco = nil, iEMS = nil)
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
		directory =  Rails.root.join('public', 'reports')
		Dir.mkdir(directory) unless File.exists?(directory)

		directory =  Rails.root.join('public', 'reports', 'employee dtr')
		Dir.mkdir(directory) unless File.exists?(directory)
		
	 	report_zip_path = Rails.root.join('public', 'reports', self.name)
		
		Zip::File.open(report_zip_path, Zip::File::CREATE) { |zipfile|
			dtr_summary_filename = "DTRSUMMARY.xlsx"
			dtr_summary_path = Rails.root.join('public', 'reports', dtr_summary_filename)

			summarydtr = Axlsx::Package.new
	 
			# Required for use with numbers
			summarydtr.use_shared_strings = true
			
			summarydtr.workbook do |summarydtr_wb|
			# define your regular styles
				styles = summarydtr_wb.styles
				title = styles.add_style sz: 15, b: true, u: true
				headers = styles.add_style sz: 11, b: true, border: {:style => :thick, :color => '00000000', :edges => [:top, :left, :right, :bottom] }, alignment: { :horizontal => :center, :vertical => :center, :wrap_text => true}
				tabledata_total_total = styles.add_style sz: 11, border: {:style => :thick, :color => '000000', :edges => [:left, :right] }, alignment: { :horizontal => :center, :vertical => :center, :wrap_text => true}
				bottom_border = styles.add_style border: {:style => :thick, :color => '00000000', :edges => [:top] }
				summaryrownum = 0

				
				summarydtr_wb.add_worksheet(name: 'DTR SUMMARY') do  |summarydtr_ws|
					summarydtr_ws.add_row ["iRipple, Inc. | DTR Summary Sheet for the period #{self.date_start.strftime('%B %d, %Y')} to #{self.date_end.strftime('%B %d, %Y')}"], style: title
					summaryrownum += 1
				    summarydtr_ws.add_row ["Employee Information", " ", " ", 
				    					   "TARDINESS", " ", " ", 
				    					   "SL", " ", 
				    					   "VL", " ", 
				    					   "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "AA", "AB", "AC", "AD", "AE", "AF", "AG", " AH", "AI", "AJ", "AK", "AL", " AM", "AN", "AO", "AP", "AQ", "AR", "AS", 
				    					   "TOTAL DEDUCTION", # AT
				    					   "OT", # AU
				    					   " ", # AV
				    					   " ", # AW
				    					   " ", # AX
				    					   " ", # AY
				    					   " ", # AZ
				    					   " ", # BA
				    					   " ", # BB
				    					   " ", # BC
				    					   " ", # BD
				    					   " ", # BE
				    					   " ", # BF
				    					   " ", # BG
				    					   " ", # BH
				    					   " ", # BI
				    					   " ", # BJ
				    					   " ", # BK
				    					   " ", # BL
				    					   " ", # BM
				    					   " ", # BN
				    					   " ", # BO
				    					   " ", # BP
				    					   " ", # BQ
				    					   " ", # BR
				    					   " ", # BS
				    					   " ", # BT
				    					   " ", # BU
				    					   " ", # BV
				    					   " ", # BW
				    					   " ", # BX
				    					   " ", # BY
				    					   " ", # BZ
				    					   " ", # CA
				    					   " ", # CB
				    					   " ", # CC
				    					   " ", # CD
				    					   " ", # CE
				    					   "Deduction", # CF
				    					   " ", # CG
				    					   " ", # CH
				    					   " ", # CI
				    					   " ", # CJ
				    					   " "], style: headers # CK
				    					   
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
				    					   "REST DAY OR SPECIAL PUBLIC HOLIDAY",
				    					   "SPECIAL PUBLIC HOLIDAY ON REST DAY",
				    					   "REGULAR HOLIDAY", 
				    					   "REGULAR HOLIDAY ON REST DAY",
				    					   " ", " ", " ", " ", " ", " ", " ", " ", " ", " ",
				    					   " ", " ", " ", " ", " ", " ", " ", " ", " ", " ",
				    					   " ", " ", " ", " ", " ", " ", " ", " ", " ", " ",
				    					   "ALLOWANCE", "TOTAL",
				    					   "Absences", "1st Column", "2nd Column", "3rd Column", "4th Column", "5th Column"], :height => 70, style: headers
				    summaryrownum += 1
				    # Otherwise you can specify a style for each column.
				    # summarydtr_ws.add_row ['Q1-2011', '26740000000', '=B5/SUM(B4:B7)'], style: [pascal, money_pascal, percent_pascal]

				    # You can merge cells!
				    summarydtr_ws.merge_cells 'A1:CK1'
				    summarydtr_ws.merge_cells 'A2:C2'
				    summarydtr_ws.merge_cells 'D2:F2'
				    summarydtr_ws.merge_cells 'G2:H2'
				    summarydtr_ws.merge_cells 'I2:J2'
				    summarydtr_ws.merge_cells 'AU2:CE2'
				    summarydtr_ws.merge_cells 'CF2:CK2'
				    
				    ids = self.employee_ids.tr('"[]','').split(",")
					@employees = Employee.find(ids).sort_by{|i| [i.last_name, i.first_name, i.department]}
				    
				    # Employee.all.order(last_name: :asc).each_with_index do |emp, i|
				    @employees.each_with_index do |emp, i|
				    	@@total_absences = 0
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
							titlelegend = styles.add_style sz: 15, b: true, u: true, border: {:style => :thick, :color => '000000', :edges => [:top, :left, :right, :bottom] }
							headers = styles.add_style sz: 11, b: true, border: {:style => :thick, :color => '000000', :edges => [:top, :left, :right, :bottom] }, alignment: { :horizontal => :center, :vertical => :center, :wrap_text => true}
							tabledata = styles.add_style sz: 11, border: {:style => :thick, :color => '000000', :edges => [:left, :right] }, alignment: { :horizontal => :center, :vertical => :center, :wrap_text => true}
							bottomborder = styles.add_style sz: 11, border: {:style => :thick, :color => '000000', :edges => [:top] }, alignment: { :horizontal => :center, :vertical => :center, :wrap_text => true}
							bottomleftrightborder = styles.add_style sz: 11, border: {:style => :thick, :color => '000000', :edges => [:top, :left, :right] }, alignment: { :horizontal => :center, :vertical => :center, :wrap_text => true}
							info = styles.add_style :bg_color => "66A3FF", sz: 11, border: {:style => :thick, :color => '000000', :edges => [:left, :right] }, alignment: { :horizontal => :center, :vertical => :center, :wrap_text => true}
							warning = styles.add_style :bg_color => "FFCC66", sz: 11, border: {:style => :thick, :color => '000000', :edges => [:left, :right] }, alignment: { :horizontal => :center, :vertical => :center, :wrap_text => true}
							danger = styles.add_style :bg_color => "DF5E5E", sz: 11, border: {:style => :thick, :color => '000000', :edges => [:left, :right] }, alignment: { :horizontal => :center, :vertical => :center, :wrap_text => true}
							legendblue = styles.add_style :bg_color => "66A3FF", border: {:style => :thick, :color => '000000', :edges => [:left] }
							legendorange = styles.add_style :bg_color => "FFCC66", border: {:style => :thick, :color => '000000', :edges => [:left] }
							legendred = styles.add_style :bg_color => "DF5E5E", border: {:style => :thick, :color => '000000', :edges => [:left] }
							legenddescription = styles.add_style sz: 11, b: true, u: true, border: {:style => :thick, :color => '000000', :edges => [:top, :left, :right] }
							totalheader = styles.add_style sz: 11, border: {:style => :thick, :color => '000000', :edges => [:top, :left, :right, :bottom] }, alignment: { :horizontal => :right, :vertical => :center, :wrap_text => true}
							tabledata_total = styles.add_style sz: 11, border: {:style => :thick, :color => '000000', :edges => [:left, :right, :top, :bottom] }, alignment: { :horizontal => :center, :vertical => :center, :wrap_text => true}
							if @@report.include? :panes
								employeedtr_wb.add_worksheet(name: 'EMPLOYEE DTR') do  |employeedtr_ws|
									employeedtr_ws.add_row ['iRipple, Inc.'], style: title
									if emp.is_manager
										employeedtr_ws.add_row ["Name: #{emp.last_name}, #{emp.first_name} - Manager"], style: title
									else
										employeedtr_ws.add_row ["Name: #{emp.last_name}, #{emp.first_name}"], style: title
									end
									employeedtr_ws.add_row ["Department: #{emp.department}"], style: title
					   				employeedtr_ws.add_row ["DATE", "DAY", "TIME IN", "TIME OUT", 
					   										"NO. OF HOURS LATE", "NO. OF HOURS UNDERTIME", "NO. OF OVERTIME HOURS", "VACATION LEAVE", "SICK LEAVE",
					   										"APPROVED UNDERTIME", "OFFICIAL BUSINESS DEPARTURE", "OFFICIAL BUSINESS TIME START", "OFFICIAL BUSINESS TIME END", "OFFICIAL BUSINESS ARRIVAL", "OFFSET" , "REMARKS"], :height => 50, style: headers
		    						employeedtr_ws.merge_cells 'A1:P1'
					    			employeedtr_ws.merge_cells 'A2:P2'
					    			employeedtr_ws.merge_cells 'A3:P3'
									
									date = self.date_start
									rownum = 5
									@@days_over_cutoffdate = 0
									while date <= self.date_end
										e = emp.get_all_information(date)
										if e[:remarks] != ''
											employeedtr_ws.add_row [date.strftime('%m-%d-%Y'),
																    date.strftime('%A'),
																    e[:time_in],
																    e[:time_out], 
																    (e[:no_of_hours_late] if e[:no_of_hours_late] != 0),
																    (e[:no_of_hours_undertime] if e[:no_of_hours_undertime] != 0),
																    (e[:ot_for_the_day] if e[:ot_for_the_day] != 0),
																    (e[:vacation_leave] if e[:vacation_leave] != 0),
																    (e[:sick_leave] if e[:sick_leave] != 0),
																    (e[:ut_time].to_time.strftime('%H:%M:%S') unless e[:ut_time].to_time.strftime('%H:%M:%S') == '00:00:00'),		
																    (e[:ob_departure].strftime('%H:%M:%S') unless e[:ob_departure].nil? || (e[:ob_departure].is_a? Integer)),
																    (e[:ob_time_start].strftime('%H:%M:%S') unless e[:ob_time_start].nil? || (e[:ob_time_start].is_a? Integer)),
																    (e[:ob_time_end].strftime('%H:%M:%S') unless e[:ob_time_end].nil? || (e[:ob_time_end].is_a? Integer)),
																    (e[:ob_arrival].strftime('%H:%M:%S') unless e[:ob_arrival].nil? || (e[:ob_arrival].is_a? Integer)),
																    e[:offset],
																    e[:remarks]], style: info
										elsif e[:is_halfday]
											@@total_absences += 0.5
											employeedtr_ws.add_row [date.strftime('%m-%d-%Y'),
																    date.strftime('%A'),
																    e[:time_in],
																    e[:time_out], 
																    (e[:no_of_hours_late] if e[:no_of_hours_late] != 0),
																    (e[:no_of_hours_undertime] if e[:no_of_hours_undertime] != 0),
																    (e[:ot_for_the_day] if e[:ot_for_the_day] != 0),
																    (e[:vacation_leave] if e[:vacation_leave] != 0),
																    (e[:sick_leave] if e[:sick_leave] != 0),
																    (e[:ut_time].to_time.strftime('%H:%M:%S') unless e[:ut_time].to_time.strftime('%H:%M:%S') == '00:00:00'),		
																    (e[:ob_departure].strftime('%H:%M:%S') unless e[:ob_departure].nil? || (e[:ob_departure].is_a? Integer)),
																    (e[:ob_time_start].strftime('%H:%M:%S') unless e[:ob_time_start].nil? || (e[:ob_time_start].is_a? Integer)),
																    (e[:ob_time_end].strftime('%H:%M:%S') unless e[:ob_time_end].nil? || (e[:ob_time_end].is_a? Integer)),
																    (e[:ob_arrival].strftime('%H:%M:%S') unless e[:ob_arrival].nil? || (e[:ob_arrival].is_a? Integer)),
																    e[:offset],
																    e[:remarks]], style: warning
									    elsif e[:is_absent]
									    	@@total_absences += 1
									    	employeedtr_ws.add_row [date.strftime('%m-%d-%Y'),
																    date.strftime('%A'),
																    e[:time_in],
																    e[:time_out], 
																    (e[:no_of_hours_late] if e[:no_of_hours_late] != 0),
																    (e[:no_of_hours_undertime] if e[:no_of_hours_undertime] != 0),
																    (e[:ot_for_the_day] if e[:ot_for_the_day] != 0),
																    (e[:vacation_leave] if e[:vacation_leave] != 0),
																    (e[:sick_leave] if e[:sick_leave] != 0),
																    (e[:ut_time].to_time.strftime('%H:%M:%S') unless e[:ut_time].to_time.strftime('%H:%M:%S') == '00:00:00'),		
																    (e[:ob_departure].strftime('%H:%M:%S') unless e[:ob_departure].nil? || (e[:ob_departure].is_a? Integer)),
																    (e[:ob_time_start].strftime('%H:%M:%S') unless e[:ob_time_start].nil? || (e[:ob_time_start].is_a? Integer)),
																    (e[:ob_time_end].strftime('%H:%M:%S') unless e[:ob_time_end].nil? || (e[:ob_time_end].is_a? Integer)),
																    (e[:ob_arrival].strftime('%H:%M:%S') unless e[:ob_arrival].nil? || (e[:ob_arrival].is_a? Integer)),
																    e[:offset],
																    e[:remarks]], style: danger
									    else
									    	employeedtr_ws.add_row [date.strftime('%m-%d-%Y'),
																    date.strftime('%A'),
																    e[:time_in],
																    e[:time_out], 
																    (e[:no_of_hours_late] if e[:no_of_hours_late] != 0),
																    (e[:no_of_hours_undertime] if e[:no_of_hours_undertime] != 0),
																    (e[:ot_for_the_day] if e[:ot_for_the_day] != 0),
																    (e[:vacation_leave] if e[:vacation_leave] != 0),
																    (e[:sick_leave] if e[:sick_leave] != 0),
																    (e[:ut_time].to_time.strftime('%H:%M:%S') unless e[:ut_time].to_time.strftime('%H:%M:%S') == '00:00:00'),		
																    (e[:ob_departure].strftime('%H:%M:%S') unless e[:ob_departure].nil? || (e[:ob_departure].is_a? Integer)),
																    (e[:ob_time_start].strftime('%H:%M:%S') unless e[:ob_time_start].nil? || (e[:ob_time_start].is_a? Integer)),
																    (e[:ob_time_end].strftime('%H:%M:%S') unless e[:ob_time_end].nil? || (e[:ob_time_end].is_a? Integer)),
																    (e[:ob_arrival].strftime('%H:%M:%S') unless e[:ob_arrival].nil? || (e[:ob_arrival].is_a? Integer)),
																    e[:offset],
																    e[:remarks]], style: tabledata
										end

										rownum += 1
							        	date += 1.day #FOR USING DATE START AND DATE END AS BASIS FOR LOOP
							        	if ((@@cut_off_date.to_date >= self.date_start.to_date) && (@@cut_off_date.to_date <= self.date_end.to_date))
							        		if date.to_date >= @@cut_off_date.to_date
							        			@@days_over_cutoffdate += 1
							        		end
							        	end
							    	end
							    	if ((@@cut_off_date.to_date >= self.date_start.to_date) && (@@cut_off_date.to_date <= self.date_end.to_date))
								    	employeedtr_ws.add_row ["NUMBER OF TIMES TARDY", " ", " ", " ", "=COUNT(E5:E#{rownum-(@@days_over_cutoffdate)})", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " "], style: [totalheader, totalheader, totalheader, totalheader, tabledata_total, bottomleftrightborder, bottomleftrightborder, bottomleftrightborder, bottomleftrightborder, bottomleftrightborder, bottomleftrightborder, bottomleftrightborder, bottomleftrightborder, bottomleftrightborder, bottomleftrightborder, bottomleftrightborder]
								    	employeedtr_ws.add_row ["TOTAL TARDINESS", " ", " ", " ", "=SUM(E5:E#{rownum-(@@days_over_cutoffdate)})", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " "], style: [totalheader, totalheader, totalheader, totalheader, tabledata_total, tabledata, tabledata, tabledata, tabledata, tabledata, tabledata, tabledata, tabledata, tabledata, tabledata, tabledata]
								    else
							    		employeedtr_ws.add_row ["NUMBER OF TIMES TARDY", " ", " ", " ", "=COUNT(E5:E#{rownum-1})", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " "], style: [totalheader, totalheader, totalheader, totalheader, tabledata_total, bottomleftrightborder, bottomleftrightborder, bottomleftrightborder, bottomleftrightborder, bottomleftrightborder, bottomleftrightborder, bottomleftrightborder, bottomleftrightborder, bottomleftrightborder, bottomleftrightborder, bottomleftrightborder]
								    	employeedtr_ws.add_row ["TOTAL TARDINESS", " ", " ", " ", "=SUM(E5:E#{rownum-1})", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " "], style: [totalheader, totalheader, totalheader, totalheader, tabledata_total, tabledata, tabledata, tabledata, tabledata, tabledata, tabledata, tabledata, tabledata, tabledata, tabledata, tabledata]
							    	end
							    	employeedtr_ws.merge_cells "A#{rownum}:D#{rownum}"

							    	rownum += 1
							    	employeedtr_ws.merge_cells "A#{rownum}:D#{rownum}"
							    	rownum += 1
							    	employeedtr_ws.add_row ["TOTAL OVERTIME HOURS", " ", " ", " ", " ", " ", "=SUM(G5:G#{rownum-3})", " ", " ", " ", " ", " ", " ", " ", " ", " "], style: [totalheader, totalheader, totalheader, totalheader, totalheader, totalheader, tabledata_total, tabledata, tabledata, tabledata, tabledata, tabledata, tabledata, tabledata, tabledata, tabledata]
							    	employeedtr_ws.merge_cells "A#{rownum}:F#{rownum}"
							    	rownum += 1
							    	if ((@@cut_off_date.to_date >= self.date_start.to_date) && (@@cut_off_date.to_date <= self.date_end.to_date))
						    			employeedtr_ws.add_row ["TOTAL LEAVES ACCUMULATED", " ", " ", " ", " ", " ", " ","=SUM(H5:H#{rownum-(3+@@days_over_cutoffdate)})", "=SUM(I5:I#{rownum-(3+@@days_over_cutoffdate)})", " ", " ", " ", " ", " ", " ", " "], style: [totalheader, totalheader, totalheader, totalheader, totalheader, totalheader, totalheader, tabledata_total, tabledata, tabledata, tabledata, tabledata, tabledata, tabledata, tabledata, tabledata]
						    		else
						    			employeedtr_ws.add_row ["TOTAL LEAVES ACCUMULATED", " ", " ", " ", " ", " ", " ","=SUM(H5:H#{rownum-4})", "=SUM(I5:I#{rownum-4})", " ", " ", " ", " ", " ", " ", " "], style: [totalheader, totalheader, totalheader, totalheader, totalheader, totalheader, totalheader, tabledata_total, tabledata_total, tabledata, tabledata, tabledata, tabledata, tabledata, tabledata, tabledata]
							    	end
							    	employeedtr_ws.merge_cells "A#{rownum}:G#{rownum}"
							    	rownum += 1
							    	employeedtr_ws.add_row ["TOTAL ABSENCES", " ", " ", " ", " ", " ", " ", " ", @@total_absences, " ", " ", " ", " ", " ", " ", " "], style: [totalheader, totalheader, totalheader, totalheader, totalheader, totalheader, totalheader, totalheader, tabledata_total, tabledata, tabledata, tabledata, tabledata, tabledata, tabledata, tabledata]
							    	employeedtr_ws.merge_cells "A#{rownum}:H#{rownum}"
							    	rownum += 1

							    	employeedtr_ws.add_row [" ", " ", " ", " ", " ", " ", " ", " ", " ", " ",
							    							" ", " ", " ", " ", " ", " "], style: bottomborder
							    	rownum += 1

							    	employeedtr_ws.add_row ["ACCUMULATED OT", " ", ("=FLOOR(G#{rownum-4}/8,1)&"<<'"."'<<"&FLOOR(MOD(G#{rownum-4},8),1)&"<<'"."'<<"&(MOD(G#{rownum-4},8)-FLOOR(MOD(G#{rownum-4},8),1))*60"), " ", "", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ",
							   							    "=INT(LEFT(C#{rownum+1},2))", 
							   							    "=IF(LEFT(RIGHT(C#{rownum+1},LEN(C#{rownum+1})-2),1)="<<'"."'<<",RIGHT(C#{rownum+1},LEN(C#{rownum+1})-3),RIGHT(C#{rownum+1},LEN(C#{rownum+1})-2))", 
							   							    "=INT(LEFT(R#{rownum},1))", 
							   							    "=RIGHT(R#{rownum},LEN(R#{rownum})-2)+0", 
							   							    "=Q#{rownum}*8*60+S#{rownum}*60+T#{rownum}"], style: [totalheader, totalheader, tabledata_total, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]
	   							    employeedtr_ws.merge_cells "A#{rownum}:B#{rownum}"
							    	rownum += 1

							   		employeedtr_ws.add_row ["TOTAL ABSENCES", " ", ("=FLOOR(I#{rownum-3},1)&"<<'"."'<<"&FLOOR(MOD(I#{rownum-3}*8,8),1)&"<<'"."'<<"&(MOD(I#{rownum-3}*8,8)-FLOOR(MOD(I#{rownum-3}*8,8),1))*60"), " ", "Legends:", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ",
							   							    "=INT(LEFT(C#{rownum+1},2))", 
							   							    "=IF(LEFT(RIGHT(C#{rownum+1},LEN(C#{rownum+1})-2),1)="<<'"."'<<",RIGHT(C#{rownum+1},LEN(C#{rownum+1})-3),RIGHT(C#{rownum+1},LEN(C#{rownum+1})-2))", 
							   							    "=INT(LEFT(R#{rownum},1))", 
							   							    "=RIGHT(R#{rownum},LEN(R#{rownum})-2)+0", 
							   							    "=Q#{rownum}*8*60+S#{rownum}*60+T#{rownum}"], style: [totalheader, totalheader, tabledata_total, nil, titlelegend, titlelegend, titlelegend, titlelegend, titlelegend, titlelegend, titlelegend, titlelegend, titlelegend, titlelegend, titlelegend, titlelegend]
	   							    employeedtr_ws.merge_cells "A#{rownum}:B#{rownum}"
	   							    employeedtr_ws.merge_cells "E#{rownum}:P#{rownum}"

							    	rownum += 1
							    	employeedtr_ws.add_row ["LATES", " ", ("=FLOOR(E#{rownum-7}/8,1)&"<<'"."'<<"&FLOOR(MOD(E#{rownum-7},8),1)&"<<'"."'<<"&(MOD(E#{rownum-7},8)-FLOOR(MOD(E#{rownum-7},8),1))*60"), " ", " ", "Employee has request(s)/remark(s) for that day.\n*May incur late and/or undertime depending on his or her time-in and time-out.", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ",
							    							"=INT(LEFT(C#{rownum+1},2))", 
							   							    "=IF(LEFT(RIGHT(C#{rownum+1},LEN(C#{rownum+1})-2),1)="<<'"."'<<",RIGHT(C#{rownum+1},LEN(C#{rownum+1})-3),RIGHT(C#{rownum+1},LEN(C#{rownum+1})-2))", 
							   							    "=INT(LEFT(R#{rownum},1))", 
							   							    "=RIGHT(R#{rownum},LEN(R#{rownum})-2)+0", 
							   							    "=Q#{rownum}*8*60+S#{rownum}*60+T#{rownum}"], style: [totalheader, totalheader, tabledata_total, nil, legendblue, legenddescription, legenddescription, legenddescription, legenddescription, legenddescription, legenddescription, legenddescription, legenddescription, legenddescription, legenddescription, legenddescription]
	   							    employeedtr_ws.merge_cells "A#{rownum}:B#{rownum}"
	   							    employeedtr_ws.merge_cells "E#{rownum}:E#{rownum+1}"
	   							    employeedtr_ws.merge_cells "F#{rownum}:P#{rownum+1}"
							    	rownum += 1
							    	employeedtr_ws.add_row ["ACCUMULATED VL", " ", ("=FLOOR(H#{rownum-6},1)&"<<'"."'<<"&(H#{rownum-6}-FLOOR(H#{rownum-6},1))*8&"<<'".0"'), " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ",
							    							"=INT(LEFT(C#{rownum+1},2))", 
							   							    "=IF(LEFT(RIGHT(C#{rownum+1},LEN(C#{rownum+1})-2),1)="<<'"."'<<",RIGHT(C#{rownum+1},LEN(C#{rownum+1})-3),RIGHT(C#{rownum+1},LEN(C#{rownum+1})-2))", 
							   							    "=INT(LEFT(R#{rownum},1))", 
							   							    "=RIGHT(R#{rownum},LEN(R#{rownum})-2)+0", 
							   							    "=Q#{rownum}*8*60+S#{rownum}*60+T#{rownum}"], style: [totalheader, totalheader, tabledata_total, nil, legendblue, legenddescription, legenddescription, legenddescription, legenddescription, legenddescription, legenddescription, legenddescription, legenddescription, legenddescription, legenddescription, legenddescription]
							    	employeedtr_ws.merge_cells "A#{rownum}:B#{rownum}"
							    	rownum += 1
							    	employeedtr_ws.add_row ["ACCUMULATED SL", " ", ("=FLOOR(I#{rownum-7},1)&"<<'"."'<<"&(I#{rownum-7}-FLOOR(I#{rownum-7},1))*8&"<<'".0"'), " ", " ", "Employee is considered half-day because of his time-in or time-out.", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ",
							    							"=INT(LEFT(C#{rownum+1},2))", 
							   							    "=IF(LEFT(RIGHT(C#{rownum+1},LEN(C#{rownum+1})-2),1)="<<'"."'<<",RIGHT(C#{rownum+1},LEN(C#{rownum+1})-3),RIGHT(C#{rownum+1},LEN(C#{rownum+1})-2))", 
							   							    "=INT(LEFT(R#{rownum},1))", 
							   							    "=RIGHT(R#{rownum},LEN(R#{rownum})-2)+0", 
							   							    "=Q#{rownum}*8*60+S#{rownum}*60+T#{rownum}"], style: [totalheader, totalheader, tabledata_total, nil, legendorange, legenddescription, legenddescription, legenddescription, legenddescription, legenddescription, legenddescription, legenddescription, legenddescription, legenddescription, legenddescription, legenddescription]
							    	employeedtr_ws.merge_cells "A#{rownum}:B#{rownum}"
							    	employeedtr_ws.merge_cells "E#{rownum}:E#{rownum+1}"
	   							    employeedtr_ws.merge_cells "F#{rownum}:P#{rownum+1}"
							    	rownum += 1
							    	employeedtr_ws.add_row ["VL BALANCE", " ", "#{emp.vacation_leave_balance_to_string(self.date_start)}", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ",
							    							"=INT(LEFT(C#{rownum+1},2))", 
							   							    "=IF(LEFT(RIGHT(C#{rownum+1},LEN(C#{rownum+1})-2),1)="<<'"."'<<",RIGHT(C#{rownum+1},LEN(C#{rownum+1})-3),RIGHT(C#{rownum+1},LEN(C#{rownum+1})-2))", 
							   							    "=INT(LEFT(R#{rownum},1))", 
							   							    "=RIGHT(R#{rownum},LEN(R#{rownum})-2)+0", 
							   							    "=Q#{rownum}*8*60+S#{rownum}*60+T#{rownum}"], style: [totalheader, totalheader, tabledata_total, nil, legendorange, legenddescription, legenddescription, legenddescription, legenddescription, legenddescription, legenddescription, legenddescription, legenddescription, legenddescription, legenddescription, legenddescription]
							    	employeedtr_ws.merge_cells "A#{rownum}:B#{rownum}"
							    	rownum += 1
							    	employeedtr_ws.add_row ["SL BALANCE", " ", "#{emp.sick_leave_balance_to_string(self.date_start)}", " ", " ", "Employee has no time-in and therefore, considered as absent.", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ",
							    							"=Q#{rownum-5}+Q#{rownum-6}+IF(Q#{rownum-4}>Q#{rownum-2},Q#{rownum-4}-Q#{rownum-2},0)+IF(Q#{rownum-3}>Q#{rownum-1},Q#{rownum-3}-Q#{rownum-1},0)",
							    							" ", 
							    							"=S#{rownum-5}+S#{rownum-6}+IF(S#{rownum-4}>S#{rownum-2},S#{rownum-4}-S#{rownum-2},0)+IF(S#{rownum-3}>S#{rownum-1},S#{rownum-3}-S#{rownum-1},0)",
							    							"=T#{rownum-5}+T#{rownum-6}+IF(T#{rownum-4}>T#{rownum-2},T#{rownum-4}-T#{rownum-2},0)+IF(T#{rownum-3}>T#{rownum-1},T#{rownum-3}-T#{rownum-1},0)", 
							    							"=U#{rownum-5}+U#{rownum-6}+IF(U#{rownum-4}>U#{rownum-2},U#{rownum-4}-U#{rownum-2},0)+IF(U#{rownum-3}>U#{rownum-1},U#{rownum-3}-U#{rownum-1},0)"], style: [totalheader, totalheader, tabledata_total, nil, legendred, legenddescription, legenddescription, legenddescription, legenddescription, legenddescription, legenddescription, legenddescription, legenddescription, legenddescription, legenddescription, legenddescription]
							    	employeedtr_ws.merge_cells "A#{rownum}:B#{rownum}"
							    	employeedtr_ws.merge_cells "E#{rownum}:E#{rownum+1}"
	   							    employeedtr_ws.merge_cells "F#{rownum}:P#{rownum+1}"
							    	rownum += 1
							    	employeedtr_ws.add_row ["TOTAL", " ", "=FLOOR(Q#{rownum}/8,1)&"<<'"."'<<"&FLOOR(MOD(Q#{rownum},8),1)&"<<'"."'<<"&(MOD(Q#{rownum},8)-FLOOR(MOD(Q#{rownum},8),1))*60", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ",
							    							"=U#{rownum-1}/60"], style: [totalheader, totalheader, tabledata_total, nil, legendred, legenddescription, legenddescription, legenddescription, legenddescription, legenddescription, legenddescription, legenddescription, legenddescription, legenddescription, legenddescription, legenddescription]
							    	employeedtr_ws.merge_cells "A#{rownum}:B#{rownum}"
							    	employeedtr_ws.add_row [" ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " "], style: [nil, nil, nil, nil, bottomborder, bottomborder, bottomborder, bottomborder, bottomborder, bottomborder, bottomborder, bottomborder, bottomborder, bottomborder, bottomborder, bottomborder]
							    	colnum = 16
									while colnum <= 20
										employeedtr_ws.column_info[colnum].hidden = true
										colnum += 1
									end
									employeedtr_ws.column_widths 11, 11, 9, 9,
																 8.5, 13, 11.5, 11, 8, 
																 13, 13.5, 13, 11, 11, 11, 26.5
									
								    employeedtr_ws.sheet_view.pane do |pane|
								    	pane.top_left_cell = "C5"
									    pane.state = :frozen_split
									    pane.y_split = 4
									    pane.x_split = 2
									    pane.active_pane = :bottom_right
								    end
								end
							end
						end

						employeedtr.serialize "#{dtr_peremployee_path}"	
						summary = emp.get_all_summary(self.date_start, self.date_end, @@cut_off_date)
						summarydtr_ws.add_row [i+1,"#{emp.last_name}, #{emp.first_name}", "#{emp.department}", # A B C
				    					   	summary[:number_of_times_late], # D
			    					   		summary[:total_late_to_string], # E
				    					    summary[:total_undertime_to_string], # F
				    					    summary[:total_sl_to_string], summary[:start_sick_leave_balance], # G H
				    					    summary[:total_vl_to_string], summary[:start_vacation_leave_balance], # I J
				    					    "=INT(LEFT(E#{summaryrownum+1},2))", # K
				    					    "=INT(LEFT(F#{summaryrownum+1},2))", # L
				    					    "=INT(LEFT(I#{summaryrownum+1},2))", # M
				    					    "=INT(LEFT(G#{summaryrownum+1},2))", # N
				    					    "=INT(LEFT(J#{summaryrownum+1},2))", # O
				    					    "=INT(LEFT(H#{summaryrownum+1},2))", # P
				    					    "=K#{summaryrownum+1}+L#{summaryrownum+1}+CG#{summaryrownum+1}+IF(M#{summaryrownum+1}>O#{summaryrownum+1},M#{summaryrownum+1}-O#{summaryrownum+1},0)+IF(N#{summaryrownum+1}>P#{summaryrownum+1},N#{summaryrownum+1}-P#{summaryrownum+1},0)", # Q
				    					    "=IF(LEFT(RIGHT(E#{summaryrownum+1},LEN(E#{summaryrownum+1})-2),1)="<<'"."'<<",RIGHT(E#{summaryrownum+1},LEN(E#{summaryrownum+1})-3),RIGHT(E#{summaryrownum+1},LEN(E#{summaryrownum+1})-2))", # R
				    					    "=IF(LEFT(RIGHT(F#{summaryrownum+1},LEN(F#{summaryrownum+1})-2),1)="<<'"."'<<",RIGHT(F#{summaryrownum+1},LEN(F#{summaryrownum+1})-3),RIGHT(F#{summaryrownum+1},LEN(F#{summaryrownum+1})-2))", # S
				    					    "=IF(LEFT(RIGHT(I#{summaryrownum+1},LEN(I#{summaryrownum+1})-2),1)="<<'"."'<<",RIGHT(I#{summaryrownum+1},LEN(I#{summaryrownum+1})-3),RIGHT(I#{summaryrownum+1},LEN(I#{summaryrownum+1})-2))", # T
				    					    "=IF(LEFT(RIGHT(G#{summaryrownum+1},LEN(G#{summaryrownum+1})-2),1)="<<'"."'<<",RIGHT(G#{summaryrownum+1},LEN(G#{summaryrownum+1})-3),RIGHT(G#{summaryrownum+1},LEN(G#{summaryrownum+1})-2))", # U
				    					    "=IF(LEFT(RIGHT(J#{summaryrownum+1},LEN(J#{summaryrownum+1})-2),1)="<<'"."'<<",RIGHT(J#{summaryrownum+1},LEN(J#{summaryrownum+1})-3),RIGHT(J#{summaryrownum+1},LEN(J#{summaryrownum+1})-2))", # V
				    					    "=IF(LEFT(RIGHT(H#{summaryrownum+1},LEN(H#{summaryrownum+1})-2),1)="<<'"."'<<",RIGHT(H#{summaryrownum+1},LEN(H#{summaryrownum+1})-3),RIGHT(H#{summaryrownum+1},LEN(H#{summaryrownum+1})-2))", # W
				    					    "=INT(LEFT(R#{summaryrownum+1},1))", # X
				    					    "=INT(LEFT(S#{summaryrownum+1},1))", # Y
				    					    "=INT(LEFT(T#{summaryrownum+1},1))", # Z
				    					    "=INT(LEFT(U#{summaryrownum+1},1))", # AA
				    					    "=INT(LEFT(V#{summaryrownum+1},1))", # AB
				    					    "=INT(LEFT(W#{summaryrownum+1},1))", # AC
				    					    "=R#{summaryrownum+1}+S#{summaryrownum+1}+CH#{summaryrownum+1}+IF(T#{summaryrownum+1}>V#{summaryrownum+1},T#{summaryrownum+1}-V#{summaryrownum+1},0)+IF(U#{summaryrownum+1}>W#{summaryrownum+1},U#{summaryrownum+1}-W#{summaryrownum+1},0)", # AD
				    					    "=RIGHT(R#{summaryrownum+1},LEN(R#{summaryrownum+1})-2)+0", # AE
				    					    "=RIGHT(S#{summaryrownum+1},LEN(S#{summaryrownum+1})-2)+0", # AF
				    					    "=RIGHT(T#{summaryrownum+1},LEN(T#{summaryrownum+1})-2)+0", # AG
				    					    "=RIGHT(U#{summaryrownum+1},LEN(U#{summaryrownum+1})-2)+0", # AH
				    					    "=RIGHT(V#{summaryrownum+1},LEN(V#{summaryrownum+1})-2)+0", # AI
				    					    "=RIGHT(W#{summaryrownum+1},LEN(W#{summaryrownum+1})-2)+0", # AJ
				    					    "=AE#{summaryrownum+1}+AF#{summaryrownum+1}+CJ#{summaryrownum+1}+IF(AG#{summaryrownum+1}>AI#{summaryrownum+1},AG#{summaryrownum+1}-AI#{summaryrownum+1},0)+IF(AH#{summaryrownum+1}>AJ#{summaryrownum+1},AH#{summaryrownum+1}-AJ#{summaryrownum+1},0)", # AK
				    					    "=K#{summaryrownum+1}*8*60+X#{summaryrownum+1}*60+AE#{summaryrownum+1}", # AL
				    					    "=L#{summaryrownum+1}*8*60+Y#{summaryrownum+1}*60+AF#{summaryrownum+1}", # AM
				    					    "=M#{summaryrownum+1}*8*60+Z#{summaryrownum+1}*60+AG#{summaryrownum+1}", # AN
				    					    "=N#{summaryrownum+1}*8*60+AA#{summaryrownum+1}*60+AH#{summaryrownum+1}", # AO
				    					    "=O#{summaryrownum+1}*8*60+AB#{summaryrownum+1}*60+AI#{summaryrownum+1}", # AP
				    					    "=P#{summaryrownum+1}*8*60+AC#{summaryrownum+1}*60+AJ#{summaryrownum+1}", # AQ
				    					    "=AL#{summaryrownum+1}+AM#{summaryrownum+1}+CK#{summaryrownum+1}+IF(AN#{summaryrownum+1}>AP#{summaryrownum+1},AN#{summaryrownum+1}-AP#{summaryrownum+1},0)+IF(AO#{summaryrownum+1}>AQ#{summaryrownum+1},AO#{summaryrownum+1}-AQ#{summaryrownum+1},0)", # AR
				    					    "=AR#{summaryrownum+1}/60", # AS
				    					    "=FLOOR(AS#{summaryrownum+1}/8,1)&"<<'"."'<<"&FLOOR(MOD(AS#{summaryrownum+1},8),1)&"<<'"."'<<"&(MOD(AS#{summaryrownum+1},8)-FLOOR(MOD(AS#{summaryrownum+1},8),1))*60", # AT
				    					    summary[:total_regular_ot_to_string], # AU
				    					    summary[:total_rest_or_special_ot_to_string], # AV
				    					    summary[:total_special_on_rest_ot_to_string], # AW
				    					    summary[:total_regular_holiday_ot_to_string], # AX
				    					    summary[:total_regular_on_rest_ot_to_string], # AY
				    					    "=INT(LEFT(AU#{summaryrownum+1},1))", # AZ
				    					    "=INT(LEFT(AV#{summaryrownum+1},1))", # BA
				    					    "=INT(LEFT(AW#{summaryrownum+1},1))", # BB
				    					    "=INT(LEFT(AX#{summaryrownum+1},1))", # BC
				    					    "=INT(LEFT(AY#{summaryrownum+1},1))", # BD
				    					    "=SUM(AZ#{summaryrownum+1},BA#{summaryrownum+1},BB#{summaryrownum+1},BC#{summaryrownum+1},BD#{summaryrownum+1})", # BE
				    					    "=RIGHT(AU#{summaryrownum+1},LEN(AU#{summaryrownum+1})-2)", # BF
				    					    "=RIGHT(AV#{summaryrownum+1},LEN(AV#{summaryrownum+1})-2)", # BG
				    					    "=RIGHT(AW#{summaryrownum+1},LEN(AW#{summaryrownum+1})-2)", # BH
				    					    "=RIGHT(AX#{summaryrownum+1},LEN(AX#{summaryrownum+1})-2)", # BI
				    					    "=RIGHT(AY#{summaryrownum+1},LEN(AY#{summaryrownum+1})-2)", # BJ
				    					    "=INT(LEFT(BF#{summaryrownum+1},1))", # BK
				    					    "=INT(LEFT(BG#{summaryrownum+1},1))", # BL
				    					    "=INT(LEFT(BH#{summaryrownum+1},1))", # BM
				    					    "=INT(LEFT(BI#{summaryrownum+1},1))", # BN
				    					    "=INT(LEFT(BJ#{summaryrownum+1},1))", # BO
				    					    "=SUM(BK#{summaryrownum+1}:BO#{summaryrownum+1})", # BP
				    					    "=RIGHT(BF#{summaryrownum+1},LEN(BF#{summaryrownum+1})-2)+0", # BQ
				    					    "=RIGHT(BG#{summaryrownum+1},LEN(BG#{summaryrownum+1})-2)+0", # BR
				    					    "=RIGHT(BH#{summaryrownum+1},LEN(BH#{summaryrownum+1})-2)+0", # BS
				    					    "=RIGHT(BI#{summaryrownum+1},LEN(BI#{summaryrownum+1})-2)+0", # BT
				    					    "=RIGHT(BJ#{summaryrownum+1},LEN(BJ#{summaryrownum+1})-2)+0", # BU
				    					    "=SUM(BQ#{summaryrownum+1}:BU#{summaryrownum+1})", # BV
				    					    "=AZ#{summaryrownum+1}*8*60+BK#{summaryrownum+1}*60+BQ#{summaryrownum+1}", # BW
				    					    "=BA#{summaryrownum+1}*8*60+BL#{summaryrownum+1}*60+BR#{summaryrownum+1}", # BX
				    					    "=BB#{summaryrownum+1}*8*60+BM#{summaryrownum+1}*60+BS#{summaryrownum+1}", # BY
				    					    "=BC#{summaryrownum+1}*8*60+BN#{summaryrownum+1}*60+BT#{summaryrownum+1}", # BZ
				    					    "=BD#{summaryrownum+1}*8*60+BO#{summaryrownum+1}*60+BU#{summaryrownum+1}", # CA
				    					    "=SUM(BW#{summaryrownum+1}:CA#{summaryrownum+1})", # CB
				    					    "=CB#{summaryrownum+1}/60", # CC
				    					    "0", "=FLOOR(CC#{summaryrownum+1}/8,1)&"<<'"."'<<"&FLOOR(MOD(CC#{summaryrownum+1},8),1)&"<<'"."'<<"&(MOD(CC#{summaryrownum+1},8)-FLOOR(MOD(CC#{summaryrownum+1},8),1))*60",
				    					    summary[:total_absences_to_string], #CF
				    					    "=INT(LEFT(CF#{summaryrownum+1},2))", #CG
				    					    "=IF(LEFT(RIGHT(CF#{summaryrownum+1},LEN(CF#{summaryrownum+1})-2),1)="<<'"."'<<",RIGHT(CF#{summaryrownum+1},LEN(CF#{summaryrownum+1})-3),RIGHT(CF#{summaryrownum+1},LEN(CF#{summaryrownum+1})-2))", #CH
				    					    "=INT(LEFT(CH#{summaryrownum+1},1))", #CI
				    					    "=RIGHT(CH#{summaryrownum+1},LEN(CH#{summaryrownum+1})-2)+0", #CJ
				    					    "=CG#{summaryrownum+1}*8*60+CI#{summaryrownum+1}*60+CJ#{summaryrownum+1}"], #CK
				    					    style: tabledata_total_total
						summaryrownum += 1
						
						zipfile.add("Employee/#{employeedtr_filename}", Rails.root.join('public', 'reports', 'employee dtr', employeedtr_filename))
					end
					summarydtr_ws.add_row [" ", " ", " ", " ", " ", " ", " ", " ", " ", " ",
										   " ", " ", " ", " ", " ", " ", " ", " ", " ", " ",
										   " ", " ", " ", " ", " ", " ", " ", " ", " ", " ",
										   " ", " ", " ", " ", " ", " ", " ", " ", " ", " ",
										   " ", " ", " ", " ", " ", " ", " ", " ", " ", " ",
										   " ", " ", " ", " ", " ", " ", " ", " ", " ", " ",
										   " ", " ", " ", " ", " ", " ", " ", " ", " ", " ",
										   " ", " ", " ", " ", " ", " ", " ", " ", " ", " ",
										   " ", " ", " ", " ", " ", " ", " ", " ", " "], style: bottom_border #border of bottom cell


					summarydtr_ws.column_info[2].hidden = true
					i = 10
					while i <= 44
						summarydtr_ws.column_info[i].hidden = true
						i += 1
			        end
			        i = 51
			        while i <= 80
			        	summarydtr_ws.column_info[i].hidden = true
			        	i += 1
			        end
			        i = 83
			        while i <= 88
			        	summarydtr_ws.column_info[i].hidden = true
			        	i += 1
			        end
					summarydtr_ws.column_widths 5.25, 27.25, 26.25, 
												13.5, 9.25, 12.5,
												9.5, 11, 9.5, 11,
												nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
												19.5,
												10.9, 10, 10.5, 10.9, 10.9,
												nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 
												14, 9, 12.5, nil, nil, nil, nil, nil
					summarydtr_ws.sheet_view.pane do |pane|
				    	pane.top_left_cell = "D4"
					    pane.state = :frozen_split
					    pane.y_split = 3
					    pane.x_split = 3
					    pane.active_pane = :bottom_right
				    end
				end
			end
			summarydtr.serialize "#{dtr_summary_path}"
			zipfile.add('DTR_Summary.xlsx', dtr_summary_path)
		}
	end
end