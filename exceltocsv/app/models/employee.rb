require 'csv'
require 'pathname'

class Employee < ActiveRecord::Base
	has_many :attendances
	has_many :requests
	@@required_time_in = '08:30:00'.to_time
	@@required_time_out_MH = '18:30:00'.to_time
	@@required_time_out_F = '17:30:00'.to_time
	@@half_day_time_in = '10:00:00'.to_time
	@@half_day_time_out = '16:30:00'.to_time

	def time_in(date)
		@attendance = Attendance.where(employee_id: self.id, attendance_date: date).first
		return @attendance.time_in.to_time.strftime('%H:%M:%S') unless @attendance.nil?
	end

	def time_out(date)
		@attendance = Attendance.where(employee_id: self.id, attendance_date: date).first
		return @attendance.time_out.to_time.strftime('%H:%M:%S') unless @attendance.nil? || @attendance.time_out.nil?
	end

	def ut_time(date) 
		@request = Request.where(employee_id: self.id, date: date).first
		return '00:00:00'.to_time if @request.nil? || @request.ut_time == 0 
		return @request.ut_time
	end

	def regular_ot(date)
		@request = Request.where(employee_id: self.id, date: date).first
		return @request.regular_ot
	end

	def rest_or_special_ot(date)
		@request = Request.where(employee_id: self.id, date: date).first
		return @request.rest_or_special_ot
	end
	
	def special_on_rest_ot(date)
		@request = Request.where(employee_id: self.id, date: date).first
		return @request.special_on_rest_ot
	end

	def regular_holiday_ot(date)
		@request = Request.where(employee_id: self.id, date: date).first
		return @request.regular_holiday_ot
	end

	def regular_on_rest_ot(date)
		@request = Request.where(employee_id: self.id, date: date).first
		return @request.regular_on_rest_ot
	end

	def vacation_leave(date)
		@request = Request.where(employee_id: self.id, date: date).first
		return @request.vacation_leave
	end

	def vacation_leave_balance(date)
		@request = Request.where(employee_id: self.id, date: date).first
		return @request.vacation_leave_balance
	end

	def sick_leave(date)
		@request = Request.where(employee_id: self.id, date: date).first
		sl = @request.sick_leave
		time_in = self.time_in(date)
		time_out = self.time_out(date)
		unless @request.sick_leave != 0 || @request.vacation_leave != 0 || @request.offset.length > 2
			sl += 0.5 if (!time_out.nil? && time_out.to_time <= @@half_day_time_out) && (date.strftime('%A') != 'Saturday' && date.strftime('%A') != 'Sunday') && (@request.offset.downcase != 'pm')
			sl += 0.5 if (!time_in.nil? && time_in.to_time >= @@half_day_time_in) && (date.strftime('%A') != 'Saturday' && date.strftime('%A') != 'Sunday')  && (@request.offset.downcase != 'am')
			sl = 1 if self.is_absent?(date)
		end
		return sl
	end

	def is_halfday?(date)
		@request = Request.where(employee_id: self.id, date: date).first
		time_in = self.time_in(date)
		time_out = self.time_out(date)
		undertime = self.no_of_hours_undertime(date)
		unless @request.sick_leave != 0 || @request.vacation_leave != 0 || @request.offset.length > 2
			return true if (!time_out.nil? && time_out.to_time <= @@half_day_time_out) && (date.strftime('%A') != 'Saturday' && date.strftime('%A') != 'Sunday') && (@request.offset.downcase != 'pm')
			return true if (!time_in.nil? && time_in.to_time >= @@half_day_time_in) && (date.strftime('%A') != 'Saturday' && date.strftime('%A') != 'Sunday') && (@request.offset.downcase != 'am')
		end
		return false
	end

	def is_absent?(date)
		@request = Request.where(employee_id: self.id, date: date).first
		time_in = self.time_in(date)
		time_out = self.time_out(date)
		
		unless @request.sick_leave != 0 || @request.vacation_leave != 0 || @request.remarks.strip != '' || @request.offset.length > 2 || self.is_in_holiday?(date) 
			return true if time_in.nil? && (date.strftime('%A') != 'Saturday' && date.strftime('%A') != 'Sunday')
		end

		return false
	end

	def sick_leave_balance(date)
		@request = Request.where(employee_id: self.id, date: date).first
		return @request.sick_leave_balance
	end

	def ob_departure(date)
		@request = Request.where(employee_id: self.id, date: date).first
		return @request.ob_departure
	end

	def ob_time_start(date)
		@request = Request.where(employee_id: self.id, date: date).first
		return @request.ob_time_start
	end

	def ob_time_end(date)
		@request = Request.where(employee_id: self.id, date: date).first
		return @request.ob_time_end
	end

	def ob_arrival(date)
		@request = Request.where(employee_id: self.id, date: date).first
		return @request.ob_arrival
	end

	def offset(date)
		@request = Request.where(employee_id: self.id, date: date).first
		return @request.offset
	end

	def remarks(date)
		@request = Request.where(employee_id: self.id, date: date).first
		return @request.remarks.strip
	end

	def is_in_holiday?(date)
		@request = Request.where(employee_id: self.id, date: date).first
		token = @request.remarks.split(")::")
		
		return true if token.length == 2			
		return false
	end

	def no_of_hours_undertime(date)
		time_out = self.time_out(date)
		offset = self.offset(date).downcase
		ut_time = self.ut_time(date)
		undertime = 0
		unless time_out.nil? || offset == 'pm' || offset.length > 2
			unless self.ut_time(date).strftime('%H:%M:%S') == '00:00:00'
				undertime = Employee.format_time(ut_time.to_time - time_out.to_time) if time_out.to_time < ut_time.to_time 
			else
				if date.strftime('%A') == 'Friday'
					undertime = Employee.format_time(((@@required_time_out_F - time_out.to_time)/1.hour).round(2)) unless time_out.to_time >= @@required_time_out_F
				elsif date.strftime('%A') != 'Saturday' && date.strftime('%A') != 'Sunday'
					undertime = Employee.format_time(((@@required_time_out_MH - time_out.to_time)/1.hour).round(2)) unless time_out.to_time >= @@required_time_out_MH
				end
			end
		end
		
		return undertime unless (undertime >= 1 && date.strftime('%A') == 'Friday') || (undertime >= 2 && (date.strftime('%A') != 'Friday' && date.strftime('%A') != 'Saturday' && date.strftime('%A') != 'Sunday'))
		return 0
	end

	def no_of_hours_late(date)
		time_in = self.time_in(date)
		offset = self.offset(date).downcase
		return Employee.format_time(((time_in.to_time - @@required_time_in)/1.hour).round(2)) unless time_in.nil? || (time_in.to_time <= @@required_time_in) || date.strftime('%A') == 'Saturday' || date.strftime('%A') == 'Sunday' || self.is_manager || offset == 'am' || offset.length > 2 || time_in.to_time >= @@half_day_time_in
		return 0 
	end

	def ot_for_the_day(date)
		@request = Request.where(employee_id: self.id, date: date).first
		
		ot_for_the_day = 0
		ot_for_the_day += @request.regular_ot
		ot_for_the_day += @request.rest_or_special_ot
		ot_for_the_day += @request.special_on_rest_ot
		ot_for_the_day += @request.regular_holiday_ot
		ot_for_the_day += @request.regular_on_rest_ot
		
		return ot_for_the_day
	end

	def total_undertime(date_start, date_end)
		date = date_start
		accumulated_undertime = 0

		while date <= date_end
			accumulated_undertime += self.no_of_hours_undertime(date)
			date += 1.day
		end

		return accumulated_undertime
	end

	def total_late(date_start, date_end)
		date = date_start
		total_late = 0

		while date <= date_end
			total_late += self.no_of_hours_late(date) 			
			date += 1.day
		end

		return total_late
	end

	def number_of_times_late(date_start, date_end)
		date = date_start
		num_late = 0

		while date <= date_end
			num_late += 1 unless self.no_of_hours_late(date) == 0 			
			date += 1.day
		end

		return num_late
	end

	def total_ot_hours(date_start, date_end)
		date = date_start
		total_ot = 0

		while date <= date_end
			total_ot += self.ot_for_the_day(date)
			date += 1.day
		end

		return total_ot.round(2)
	end

	def total_vl(date_start, date_end, cut_off_date)
		date = date_start
		total_vl = 0

		while date <= date_end
			total_vl += self.vacation_leave(date) unless (cut_off_date.to_date.mon > date_start.to_date.mon && cut_off_date.to_date.mon <= date_end.to_date.mon) && date.to_date.mon >= cut_off_date.to_date.mon
			date += 1.day
		end

		return total_vl.round(2)
	end

	def total_sl(date_start, date_end, cut_off_date)
		date = date_start
		total_sl = 0

		while date <= date_end
			total_sl += self.sick_leave(date) unless (cut_off_date.to_date.mon > date_start.to_date.mon && cut_off_date.to_date.mon <= date_end.to_date.mon) && date.to_date.mon >= cut_off_date.to_date.mon
			date += 1.day
		end

		return total_sl.round(2)
	end

	def surplus_vl(date_start, date_end, cut_off_date)
		total_vl = self.total_vl(date_start, date_end, cut_off_date).to_d
		vacation_leave_balance = self.vacation_leave_balance(date_start).to_d
		return total_vl - vacation_leave_balance unless vacation_leave_balance > total_vl
		return 0
	end

	def surplus_sl(date_start, date_end, cut_off_date)
		total_sl = self.total_sl(date_start, date_end, cut_off_date).to_d
		sick_leave_balance = self.sick_leave_balance(date_start).to_d
		return total_sl - sick_leave_balance unless sick_leave_balance > total_sl
		return 0
	end

	def summary_total(date_start, date_end, cut_off_date)
		return self.surplus_vl(date_start, date_end, cut_off_date) + self.surplus_sl(date_start, date_end, cut_off_date) + self.total_late(date_start, date_end)
	end

	def summary_total_with_ut(date_start, date_end, cut_off_date)
		return self.surplus_vl(date_start, date_end, cut_off_date) + self.surplus_sl(date_start, date_end, cut_off_date) + self.total_late(date_start, date_end) + self.total_undertime(date_start, date_end)
	end

	def total_regular_ot(date_start, date_end)
		date = date_start
		accumulated_regular_ot = 0

		while date <= date_end
			accumulated_regular_ot += self.regular_ot(date)
			date += 1.day			
		end

		return accumulated_regular_ot.round(2)
	end

	def total_rest_or_special_ot(date_start, date_end)
		date = date_start
		accumulated_special_or_rest_ot = 0

		while date <= date_end
			accumulated_special_or_rest_ot += self.rest_or_special_ot(date)
			date += 1.day			
		end

		return accumulated_special_or_rest_ot.round(2)
	end

	def total_special_on_rest_ot(date_start, date_end)
		date = date_start
		accumulated_special_on_rest_ot = 0

		while date <= date_end
			accumulated_special_on_rest_ot += self.special_on_rest_ot(date)
			date += 1.day			
		end

		return accumulated_special_on_rest_ot.round(2)
	end

	def total_regular_holiday_ot(date_start, date_end)
		date = date_start
		accumulated_regular_holiday_ot = 0

		while date <= date_end
			accumulated_regular_holiday_ot += self.regular_holiday_ot(date)
			date += 1.day			
		end

		return accumulated_regular_holiday_ot.round(2)
	end

	def total_regular_on_rest_ot(date_start, date_end)
		date = date_start
		accumulated_regular_on_rest_ot = 0

		while date <= date_end
			accumulated_regular_on_rest_ot += self.regular_on_rest_ot(date)
			date += 1.day			
		end

		return accumulated_regular_on_rest_ot.round(2)
	end

	def total_ot_hours_to_string(date_start, date_end)
		value = self.total_ot_hours(date_start, date_end)
		value_days = ((value.to_d)/8).to_s.split('.').first
		value_hours = ((value.to_d)%8).to_s.split('.').first
		value_mins = ((((value.to_d)%8).to_s.split('.').last).to_d * 0.6).to_s.split('.').first

		return "#{value_days}.#{value_hours}.#{value_mins}" unless value_mins == '3'
		return "#{value_days}.#{value_hours}.#{value_mins}0"
	end

	def total_late_to_string(date_start, date_end)
		value = self.total_late(date_start, date_end)
		value_days = ((value.to_d)/8).to_s.split('.').first
		value_hours = ((value.to_d)%8).to_s.split('.').first
		value_mins = ((((value.to_d)%8).to_s.split('.').last).to_d * 0.6).to_s.split('.').first

		return "#{value_days}.#{value_hours}.#{value_mins}" unless value_mins == '3'
		return "#{value_days}.#{value_hours}.#{value_mins}0"
	end

	def total_undertime_to_string(date_start, date_end)
		value = self.total_undertime(date_start, date_end)
		value_days = ((value.to_d)/8).to_s.split('.').first
		value_hours = ((value.to_d)%8).to_s.split('.').first
		value_mins = ((((value.to_d)%8).to_s.split('.').last).to_d * 0.6).to_s.split('.').first

		return "#{value_days}.#{value_hours}.#{value_mins}" unless value_mins == '3'
		return "#{value_days}.#{value_hours}.#{value_mins}0"
	end

	def total_vl_to_string(date_start, date_end, cut_off_date)
		value = self.total_vl(date_start, date_end, cut_off_date)
		value_days = (value.to_d).to_s.split('.').first
		value_hours = (value.to_d).to_s.split('.').last

		return "#{value_days}.#{value_hours}.0"
	end

	def total_sl_to_string(date_start, date_end, cut_off_date)
		value = self.total_sl(date_start, date_end, cut_off_date)
		value_days = (value.to_d).to_s.split('.').first
		value_hours = (value.to_d).to_s.split('.').last

		return "#{value_days}.#{value_hours}.0"
	end

	def vacation_leave_balance_to_string(date)
		value = self.vacation_leave_balance(date)
		value_days = (value.to_d).to_s.split('.').first
		value_hours = ((value.to_d)*0.8).to_s.split('.').last

		return "#{value_days}.#{value_hours}.0"
	end

	def sick_leave_balance_to_string(date)
		value = self.sick_leave_balance(date)
		value_days = (value.to_d).to_s.split('.').first
		value_hours = ((value.to_d)*0.8).to_s.split('.').last

		return "#{value_days}.#{value_hours}.0"
	end

	def summary_total_to_string(date_start, date_end, cut_off_date)
		value = self.summary_total(date_start, date_end, cut_off_date)
		value_days = ((value.to_d)/8).to_s.split('.').first
		value_hours = ((value.to_d)%8).to_s.split('.').first
		value_mins = ((((value.to_d)%8).to_s.split('.').last).to_d * 0.6).to_s.split('.').first

		return "#{value_days}.#{value_hours}.#{value_mins}" unless value_mins == '3'
		return "#{value_days}.#{value_hours}.#{value_mins}0"
	end

	def summary_total_with_ut_to_string(date_start, date_end, cut_off_date)
		value = self.summary_total_with_ut(date_start, date_end, cut_off_date)
		value_days = ((value.to_d)/8).to_s.split('.').first
		value_hours = ((value.to_d)%8).to_s.split('.').first
		value_mins = ((((value.to_d)%8).to_s.split('.').last).to_d * 0.6).to_s.split('.').first

		return "#{value_days}.#{value_hours}.#{value_mins}" unless value_mins == '3'
		return "#{value_days}.#{value_hours}.#{value_mins}0"
	end

	def total_regular_ot_to_string(date_start, date_end)
		value = total_regular_ot(date_start, date_end)
		value_days = ((value.to_d)/8).to_s.split('.').first
		value_hours = ((value.to_d)%8).to_s.split('.').first
		value_mins = ((((value.to_d)%8).to_s.split('.').last).to_d * 0.6).to_s.split('.').first
		if value_mins == '3'
			return "#{value_days}.#{value_hours}.#{value_mins}0"
		end
		return "#{value_days}.#{value_hours}.#{value_mins}"
	end

	def total_rest_or_special_ot_to_string_first_8(date_start, date_end)
		value = total_rest_or_special_ot(date_start, date_end)
		return "1.0.0" if value > 8
		
		value_days = ((value.to_d)/8).to_s.split('.').first
		value_hours = ((value.to_d)%8).to_s.split('.').first
		value_mins = ((((value.to_d)%8).to_s.split('.').last).to_d * 0.6).to_s.split('.').first
		if value_mins == '3'
			return "#{value_days}.#{value_hours}.#{value_mins}0"
		end
		return "#{value_days}.#{value_hours}.#{value_mins}"
	end

	def total_rest_or_special_ot_to_string_excess(date_start, date_end)
		value = total_rest_or_special_ot(date_start, date_end)
		return "0.0.0" if value <= 8
		
		value_days = (((value.to_d)-8)/8).to_s.split('.').first
		value_hours = (((value.to_d)-8)%8).to_s.split('.').first
		value_mins = (((((value.to_d)-8)%8).to_s.split('.').last).to_d * 0.6).to_s.split('.').first
		if value_mins == '3'
			return "#{value_days}.#{value_hours}.#{value_mins}0"
		end
		return "#{value_days}.#{value_hours}.#{value_mins}"
	end

	def total_special_on_rest_ot_to_string_first_8(date_start, date_end)
		value = total_special_on_rest_ot(date_start, date_end)
		return "1.0.0" if value > 8
		
		value_days = ((value.to_d)/8).to_s.split('.').first
		value_hours = ((value.to_d)%8).to_s.split('.').first
		value_mins = ((((value.to_d)%8).to_s.split('.').last).to_d * 0.6).to_s.split('.').first
		if value_mins == '3'
			return "#{value_days}.#{value_hours}.#{value_mins}0"
		end
		return "#{value_days}.#{value_hours}.#{value_mins}"
	end

	def total_special_on_rest_ot_to_string_excess(date_start, date_end)
		value = total_special_on_rest_ot(date_start, date_end)
		return "0.0.0" if value <= 8
		
		value_days = (((value.to_d)-8)/8).to_s.split('.').first
		value_hours = (((value.to_d)-8)%8).to_s.split('.').first
		value_mins = (((((value.to_d)-8)%8).to_s.split('.').last).to_d * 0.6).to_s.split('.').first
		if value_mins == '3'
			return "#{value_days}.#{value_hours}.#{value_mins}0"
		end
		return "#{value_days}.#{value_hours}.#{value_mins}"
	end

	def total_regular_holiday_ot_to_string_first_8(date_start, date_end)
		value = total_regular_holiday_ot(date_start, date_end)
		return "1.0.0" if value > 8
		
		value_days = ((value.to_d)/8).to_s.split('.').first
		value_hours = ((value.to_d)%8).to_s.split('.').first
		value_mins = ((((value.to_d)%8).to_s.split('.').last).to_d * 0.6).to_s.split('.').first
		if value_mins == '3'
			return "#{value_days}.#{value_hours}.#{value_mins}0"
		end
		return "#{value_days}.#{value_hours}.#{value_mins}"
	end

	def total_regular_holiday_ot_to_string_excess(date_start, date_end)
		value = total_regular_holiday_ot(date_start, date_end)
		return "0.0.0" if value <= 8
		
		value_days = (((value.to_d)-8)/8).to_s.split('.').first
		value_hours = (((value.to_d)-8)%8).to_s.split('.').first
		value_mins = (((((value.to_d)-8)%8).to_s.split('.').last).to_d * 0.6).to_s.split('.').first
		if value_mins == '3'
			return "#{value_days}.#{value_hours}.#{value_mins}0"
		end
		return "#{value_days}.#{value_hours}.#{value_mins}"
	end

	def total_regular_on_rest_ot_to_string_first_8(date_start, date_end)
		value = total_regular_on_rest_ot(date_start, date_end)
		return "1.0.0" if value > 8
		
		value_days = ((value.to_d)/8).to_s.split('.').first
		value_hours = ((value.to_d)%8).to_s.split('.').first
		value_mins = ((((value.to_d)%8).to_s.split('.').last).to_d * 0.6).to_s.split('.').first
		if value_mins == '3'
			return "#{value_days}.#{value_hours}.#{value_mins}0"
		end
		return "#{value_days}.#{value_hours}.#{value_mins}"
	end

	def total_regular_on_rest_ot_to_string_excess(date_start, date_end)
		value = total_regular_on_rest_ot(date_start, date_end)
		return "0.0.0" if value <= 8
		
		value_days = (((value.to_d)-8)/8).to_s.split('.').first
		value_hours = (((value.to_d)-8)%8).to_s.split('.').first
		value_mins = (((((value.to_d)-8)%8).to_s.split('.').last).to_d * 0.6).to_s.split('.').first
		if value_mins == '3'
			return "#{value_days}.#{value_hours}.#{value_mins}0"
		end
		return "#{value_days}.#{value_hours}.#{value_mins}"
	end

	def self.format_time(to_convert)
		time = (((to_convert)).to_s.split('.').first).to_d
		time_min = ((((((to_convert)).round(2)).to_s.split('.').last).to_d)/100) * 60
		
		if time_min >= 46
			time += 1
		elsif time_min >= 31
			time += 0.75
		elsif time_min >= 16
			time += 0.5
		elsif time_min >= 1
			time += 0.25
		end
		
		return time	
	end

	def self.import(file=nil)
		if !file.nil?
			csvFile = CSV.open(file.path, 'r:ISO-8859-1')
			csvFile.each_with_index do |row|
				token = row.to_s.split(/,(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)/).flatten.compact
				id = token[0].tr('[]" ', '')
				last_name = token[1].tr('[]"', '')
				first_name = token[2].tr('[]"', '')
				department = token[3].tr('[]"', '')
				biometrics_id = token[4].tr('[] "', '')
				falco_id = token[5].tr('[] "', '')
				@employee = Employee.where(id: id).first
				if !@employee.nil?
					Employee.where(id: id).update_all(last_name: last_name, first_name: first_name, department: department, biometrics_id: biometrics_id, falco_id: falco_id)
				else
					@employee = Employee.new
					@employee.id = id
					@employee.last_name = last_name
					@employee.first_name = first_name
					@employee.department = department
					@employee.biometrics_id = biometrics_id
					@employee.falco_id = falco_id
					@employee.save
				end
			end
		end
	end

	def get_all_information(date )
		all_info = Hash.new

		@attendance = Attendance.where(employee_id: self.id, attendance_date: date).first
		@request = Request.where(employee_id: self.id, date: date).first

		time_in = @attendance.time_in.to_time.strftime('%H:%M:%S') unless @attendance.nil?
		all_info[:time_in] = time_in

		time_out = @attendance.time_out.to_time.strftime('%H:%M:%S') unless @attendance.nil? || @attendance.time_out.nil?
		all_info[:time_out] = time_out

		if @request.nil? || @request.ut_time == 0 
			ut_time = '00:00:00'.to_time
		else
			ut_time = @request.ut_time
		end
		all_info[:ut_time] = ut_time

		regular_ot = @request.regular_ot
		all_info[:regular_ot] = regular_ot

		rest_or_special_ot = @request.rest_or_special_ot
		all_info[:rest_or_special_ot] = rest_or_special_ot

		special_on_rest_ot = @request.special_on_rest_ot
		all_info[:special_on_rest_ot] = special_on_rest_ot

		regular_holiday_ot = @request.regular_holiday_ot
		all_info[:regular_holiday_ot] = regular_holiday_ot

		regular_on_rest_ot = @request.regular_on_rest_ot
		all_info[:regular_on_rest_ot] = regular_on_rest_ot


		offset = @request.offset
		all_info[:offset] = offset
		
		remarks = @request.remarks.strip
		all_info[:remarks] = remarks

		unless time_in.nil? || (time_in.to_time <= @@required_time_in) || date.strftime('%A') == 'Saturday' || date.strftime('%A') == 'Sunday' || self.is_manager || offset == 'am' || offset.length > 2 || time_in.to_time >= @@half_day_time_in
			no_of_hours_late = Employee.format_time(((time_in.to_time - @@required_time_in)/1.hour).round(2))
		else
			no_of_hours_late = 0
		end
		all_info[:no_of_hours_late] = no_of_hours_late


		no_of_hours_undertime = 0
		unless time_out.nil? || offset.downcase == 'pm' || offset.length > 2
			unless ut_time.strftime('%H:%M:%S') == '00:00:00'
				no_of_hours_undertime = Employee.format_time(ut_time.to_time - time_out.to_time) if time_out.to_time < ut_time.to_time 
			else
				if date.strftime('%A') == 'Friday'
					no_of_hours_undertime = Employee.format_time(((@@required_time_out_F - time_out.to_time)/1.hour).round(2)) unless time_out.to_time >= @@required_time_out_F
				elsif date.strftime('%A') != 'Saturday' && date.strftime('%A') != 'Sunday'
					no_of_hours_undertime = Employee.format_time(((@@required_time_out_MH - time_out.to_time)/1.hour).round(2)) unless time_out.to_time >= @@required_time_out_MH
				end
			end
		end
		unless (no_of_hours_undertime >= 1 && date.strftime('%A') == 'Friday') || (no_of_hours_undertime >= 2 && (date.strftime('%A') != 'Friday' && date.strftime('%A') != 'Saturday' && date.strftime('%A') != 'Sunday'))
			all_info[:no_of_hours_undertime] = no_of_hours_undertime
		else
			all_info[:no_of_hours_undertime] = 0
		end

		vacation_leave = @request.vacation_leave
		all_info[:vacation_leave] = vacation_leave
		
		vacation_leave_balance = @request.vacation_leave_balance 
		all_info[:vacation_leave_balance] = vacation_leave_balance

		token = @request.remarks.split(")::")
		if token.length == 2
			is_in_holiday = true 			
		else
			is_in_holiday = false
		end
		all_info[:is_in_holiday] = is_in_holiday

		unless @request.sick_leave != 0 || @request.vacation_leave != 0 || @request.remarks.strip != '' || @request.offset.length > 2 || is_in_holiday
			if time_in.nil? && (date.strftime('%A') != 'Saturday' && date.strftime('%A') != 'Sunday')
				is_absent = true
			else
				is_absent = false
			end
		else
			is_absent = false
		end
		all_info[:is_absent] = is_absent

		sick_leave = @request.sick_leave
		unless @request.sick_leave != 0 || @request.vacation_leave != 0 || @request.offset.length > 2
			sick_leave += 0.5 if (!time_out.nil? && time_out.to_time <= @@half_day_time_out) && (date.strftime('%A') != 'Saturday' && date.strftime('%A') != 'Sunday') && (@request.offset.downcase != 'pm')
			sick_leave += 0.5 if (!time_in.nil? && time_in.to_time >= @@half_day_time_in) && (date.strftime('%A') != 'Saturday' && date.strftime('%A') != 'Sunday')  && (@request.offset.downcase != 'am')
			sick_leave = 1 if is_absent
		end
		all_info[:sick_leave] = sick_leave
		
		sick_leave_balance = @request.sick_leave_balance
		all_info[:sick_leave_balance] = sick_leave_balance

		unless @request.sick_leave != 0 || @request.vacation_leave != 0 || @request.offset.length > 2
			is_halfday = true if (!time_out.nil? && time_out.to_time <= @@half_day_time_out) && (date.strftime('%A') != 'Saturday' && date.strftime('%A') != 'Sunday') && (@request.offset.downcase != 'pm')
			is_halfday = true if (!time_in.nil? && time_in.to_time >= @@half_day_time_in) && (date.strftime('%A') != 'Saturday' && date.strftime('%A') != 'Sunday') && (@request.offset.downcase != 'am')
		else
			is_halfday = false
		end
		all_info[:is_halfday] = is_halfday

		all_info[:ob_departure] = @request.ob_departure
		all_info[:ob_time_start] = @request.ob_time_start
		all_info[:ob_time_end] = @request.ob_time_end
		all_info[:ob_arrival] = @request.ob_arrival

		ot_for_the_day = 0
		ot_for_the_day += @request.regular_ot
		ot_for_the_day += @request.rest_or_special_ot
		ot_for_the_day += @request.special_on_rest_ot
		ot_for_the_day += @request.regular_holiday_ot
		ot_for_the_day += @request.regular_on_rest_ot
		all_info[:ot_for_the_day] = ot_for_the_day

		return all_info
	end

	def get_all_summary(date_start, date_end, cut_off_date)
		all_summary = Hash.new

		date = date_start
		total_undertime = 0
		total_late = 0
		number_of_times_late = 0
		total_ot_hours = 0
		total_vl = 0
		total_sl = 0
		total_regular_ot = 0
		total_rest_or_special_ot = 0
		total_special_on_rest_ot = 0
		total_regular_holiday_ot = 0
		total_regular_on_rest_ot = 0

		while date <= date_end
			e = self.get_all_information(date)
			total_undertime += e[:no_of_hours_undertime]
			total_late += e[:no_of_hours_late]
			number_of_times_late += 1 unless e[:no_of_hours_late] == 0
			total_ot_hours += e[:ot_for_the_day]
			
			unless (cut_off_date.to_date.mon > date_start.to_date.mon && cut_off_date.to_date.mon <= date_end.to_date.mon) && date.to_date.mon >= cut_off_date.to_date.mon
				total_vl += e[:vacation_leave]
				total_sl += e[:sick_leave]
			end

			total_regular_ot += e[:regular_ot]
			total_rest_or_special_ot += e[:rest_or_special_ot]
			total_special_on_rest_ot += e[:special_on_rest_ot]
			total_regular_holiday_ot += e[:regular_holiday_ot]
			total_regular_on_rest_ot += e[:regular_on_rest_ot]

			date += 1.day
		end
		all_summary[:total_undertime] = total_undertime
		all_summary[:total_late] = total_late
		all_summary[:number_of_times_late] = number_of_times_late
		all_summary[:total_ot_hours] = total_ot_hours
		all_summary[:total_vl] = total_vl
		all_summary[:total_sl] = total_sl
		all_summary[:total_regular_ot] = total_regular_ot
		all_summary[:total_rest_or_special_ot] = total_rest_or_special_ot
		all_summary[:total_special_on_rest_ot] = total_special_on_rest_ot
		all_summary[:total_regular_holiday_ot] = total_regular_holiday_ot
		all_summary[:total_regular_on_rest_ot] = total_regular_on_rest_ot

		@request = Request.where(employee_id: self.id, date: date_start).first
		unless @request.vacation_leave_balance.to_d > total_vl
			surplus_vl = total_vl - @request.vacation_leave_balance.to_d 
		else
			surplus_vl = 0
		end
		all_summary[:surplus_vl] = surplus_vl

		unless @request.sick_leave_balance.to_d > total_sl
			surplus_sl = total_sl - @request.sick_leave_balance.to_d
		else
			surplus_sl = 0
		end
		all_summary[:surplus_sl] = surplus_sl

		summary_total = surplus_vl + surplus_sl + total_late
		all_summary[:summary_total] = summary_total

		summary_total_with_ut = surplus_vl + surplus_sl + total_late + total_undertime
		all_summary[:summary_total_with_ut] = summary_total_with_ut

		summary_total_to_string = Employee.value_to_string(summary_total)
		token = summary_total_to_string.split(".")
		if token[2].length == 1
			all_summary[:summary_total_to_string] = "#{summary_total_to_string}0" 
		else
			all_summary[:summary_total_to_string] = summary_total_to_string
		end

		summary_total_with_ut_to_string = Employee.value_to_string(summary_total_with_ut)
		token = summary_total_with_ut_to_string.split(".")
		if token[2].length == 1
			all_summary[:summary_total_with_ut_to_string] = "#{summary_total_with_ut_to_string}0" 
		else
			all_summary[:summary_total_with_ut_to_string] = summary_total_with_ut_to_string
		end

		all_summary[:total_ot_hours_to_string] = Employee.value_to_string(total_ot_hours)

		total_late_to_string = Employee.value_to_string(total_late)
		token = total_late_to_string.split(".")
		if token[2].length == 1
			all_summary[:total_late_to_string] = "#{total_late_to_string}0" 
		else
			all_summary[:total_late_to_string] = total_late_to_string
		end

		total_undertime_to_string = Employee.value_to_string(total_undertime)
		token = total_undertime_to_string.split(".")
		if token[2].length == 1
			all_summary[:total_undertime_to_string] = "#{total_undertime_to_string}0" 
		else
			all_summary[:total_undertime_to_string] = total_undertime_to_string
		end

		all_summary[:total_vl_to_string] = Employee.leave_to_string(total_vl)
		all_summary[:total_sl_to_string] = Employee.leave_to_string(total_sl)

		all_summary[:start_vacation_leave_balance] = Employee.leave_to_string(@request.vacation_leave_balance)
		all_summary[:start_sick_leave_balance] = Employee.leave_to_string(@request.sick_leave_balance)

		all_summary[:total_regular_ot_to_string] = Employee.value_to_string(total_regular_ot)
		all_summary[:total_rest_or_special_ot_to_string_first_8] = Employee.value_to_string_first_8(total_rest_or_special_ot)
		all_summary[:total_special_on_rest_ot_to_string_first_8] = Employee.value_to_string_first_8(total_special_on_rest_ot)
		all_summary[:total_regular_holiday_ot_to_string_first_8] = Employee.value_to_string_first_8(total_regular_holiday_ot)
		all_summary[:total_regular_on_rest_ot_to_string_first_8] = Employee.value_to_string_first_8(total_regular_on_rest_ot)

		all_summary[:total_rest_or_special_ot_to_string_excess] = Employee.value_to_string_excess(total_rest_or_special_ot)
		all_summary[:total_special_on_rest_ot_to_string_excess] = Employee.value_to_string_excess(total_special_on_rest_ot)
		all_summary[:total_regular_holiday_ot_to_string_excess] = Employee.value_to_string_excess(total_regular_holiday_ot)
		all_summary[:total_regular_on_rest_ot_to_string_excess] = Employee.value_to_string_excess(total_regular_on_rest_ot)
		return all_summary
	end

	def self.value_to_string(value)
		value_days = ((value.to_d)/8).to_s.split('.').first
		value_hours = ((value.to_d)%8).to_s.split('.').first
		value_mins = ((((value.to_d)%8).to_s.split('.').last).to_d * 0.6).to_s.split('.').first

		return "#{value_days}.#{value_hours}.#{value_mins}"
	end

	def self.leave_to_string(value)
		value_days = (value.to_d).to_s.split('.').first
		value_hours = (value.to_d).to_s.split('.').last

		return "#{value_days}.#{value_hours}.0"
	end

	def self.value_to_string_first_8(value)
		return "1.0.0" if value > 8
		
		value_days = ((value.to_d)/8).to_s.split('.').first
		value_hours = ((value.to_d)%8).to_s.split('.').first
		value_mins = ((((value.to_d)%8).to_s.split('.').last).to_d * 0.6).to_s.split('.').first

		return "#{value_days}.#{value_hours}.#{value_mins}"
	end

	def self.value_to_string_excess(value)
		return "0.0.0" if value <= 8
		
		value_days = (((value.to_d)-8)/8).to_s.split('.').first
		value_hours = (((value.to_d)-8)%8).to_s.split('.').first
		value_mins = (((((value.to_d)-8)%8).to_s.split('.').last).to_d * 0.6).to_s.split('.').first

		return "#{value_days}.#{value_hours}.#{value_mins}"
	end
end