require 'csv'
require 'pathname'

class Employee < ActiveRecord::Base
	has_many :attendances
	has_many :requests
	# @@cutoff_date = '2015-04-01'.to_date
	@@required_time_in = '08:30:00'.to_time
	@@required_time_out_MH = '18:30:00'.to_time
	@@required_time_out_F = '17:30:00'.to_time
	@@half_day_time = '10:00:00'.to_time

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
# <<<<<<< Updated upstream
# 		sl = 0
# 		if @request.sick_leave != 0
# 			sl = @request.sick_leave
# 		else
# 			if self.is_halfday?(date)
# 				sl = 0.5
# 			end
# =======
		sl = @request.sick_leave
		time_in = self.time_in(date)
		undertime = self.no_of_hours_undertime(date)
		unless @request.sick_leave != 0 || @request.remarks.strip != ''
			sl += 0.5 if date.strftime('%A') == 'Friday' && undertime >= 1
			sl += 0.5 if date.strftime('%A') != 'Friday' && undertime >= 2
			sl += 0.5 if (!time_in.nil? && time_in.to_time >= @@half_day_time)	
# >>>>>>> Stashed changes
		end
		return sl
	end

	def is_halfday?(date)
		@request = Request.where(employee_id: self.id, date: date).first
# <<<<<<< Updated upstream
# 		unless @request.sick_leave != 0 || date.strftime('%A').to_date == 'Saturday'.to_date || date.strftime('%A') == 'Sunday'.to_date
# 			return true if date.strftime('%A') == 'Friday' && self.no_of_hours_undertime(date) >= 1
# 			return true if date.strftime('%A') != 'Friday' && self.no_of_hours_undertime(date) >= 2
# 			return true if self.no_of_hours_late(date) > 1.5
# =======
		time_in = self.time_in(date)
		undertime = self.no_of_hours_undertime(date)
		unless @request.sick_leave != 0 || @request.remarks.strip != ''
			return true if date.strftime('%A') == 'Friday' && undertime >= 1
			return true if date.strftime('%A') != 'Friday' && undertime >= 2
			return true if (!time_in.nil? && time_in.to_time >= @@half_day_time)
# >>>>>>> Stashed changes
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

	def no_of_hours_undertime(date)
# <<<<<<< Updated upstream
# 		if !self.time_out(date).nil? && self.offset(date).downcase != 'pm'
# 			if self.ut_time(date).strftime('%H:%M:%S') != '00:00:00'
# 				return Employee.format_time(self.ut_time(date).to_time - self.time_out(date).to_time)if self.time_out(date).to_time < self.ut_time(date).to_time 
# 			else
# 				if date.strftime('%A') != 'Saturday' && date.strftime('%A') != 'Sunday'
# 					if date.strftime('%A') == 'Friday'
# 						return Employee.format_time(@@required_time_out_F - self.time_out(date).to_time) unless self.time_out(date).to_time >= @@required_time_out_F
# 					else
# 						return Employee.format_time(@@required_time_out_MH - self.time_out(date).to_time) unless self.time_out(date).to_time >= @@required_time_out_MH
# 					end
# =======
		time_out = self.time_out(date)
		offset = self.offset(date).downcase
		ut_time = self.ut_time(date)
		unless time_out.nil? || offset == 'pm' || offset.length > 2 || self.remarks(date) != ''
			unless self.ut_time(date).strftime('%H:%M:%S') == '00:00:00'
				return Employee.format_time(ut_time.to_time - time_out.to_time) if time_out.to_time < ut_time.to_time 
			else
				if date.strftime('%A') == 'Friday'
					return Employee.format_time(((@@required_time_out_F - time_out.to_time)/1.hour).round(2)) unless time_out.to_time >= @@required_time_out_F
				elsif date.strftime('%A') != 'Saturday' || date.strftime('%A') != 'Sunday'
					return Employee.format_time(((@@required_time_out_MH - time_out.to_time)/1.hour).round(2)) unless time_out.to_time >= @@required_time_out_MH
# >>>>>>> Stashed changes
				end
			end
		end
		return 0
	end

	def no_of_hours_late(date)
# <<<<<<< Updated upstream
# 		if date.strftime('%A') != 'Saturday' && date.strftime('%A') != 'Sunday' && !self.is_manager && self.offset(date).downcase != 'am'
# 			if !self.time_in(date).nil? && self.time_in(date).to_time > @@required_time_in && self.time_in(date).to_time <= @@half_day_time
# 				return Employee.format_time(((self.time_in(date).to_time - @@required_time_in)/1.hour).round(2)) 
# 			end
# 		end
# 		return 0
# =======
		time_in = self.time_in(date)
		offset = self.offset(date).downcase
		return Employee.format_time(((time_in.to_time - @@required_time_in)/1.hour).round(2)) unless time_in.nil? || time_in.to_time <= @@required_time_in || date.strftime('%A') == 'Saturday' || date.strftime('%A') == 'Sunday' || self.is_manager || offset == 'am' || offset.length > 2 || time_in.to_time >= @@half_day_time || self.remarks(date) != ''
		return 0 
# >>>>>>> Stashed changes
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
		value_hours = (value.to_d).to_s.split('.').last

		return "#{value_days}.#{value_hours}.0"
	end

	def sick_leave_balance_to_string(date)
		value = self.sick_leave_balance(date)
		value_days = (value.to_d).to_s.split('.').first
		value_hours = (value.to_d).to_s.split('.').last

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

	def total_rest_or_special_ot_to_string_first_8(date_start, date_end)
		value = total_rest_or_special_ot(date_start, date_end)
		return "1.0.0" if value > 8
		
		value_days = ((value.to_d)/8).to_s.split('.').first
		value_hours = ((value.to_d)%8).to_s.split('.').first
		value_mins = ((((value.to_d)%8).to_s.split('.').last).to_d * 0.6).to_s.split('.').first
		if value_mins.to_s.length == 1 && value_mins != 0
			return "#{value_days}.#{value_hours}.#{value_mins}0"
		end
		return "#{value_days}.#{value_hours}.#{value_mins}"
	end

	def total_regular_ot_to_string(date_start, date_end)
		value = total_regular_ot(date_start, date_end)
		value_days = ((value.to_d)/8).to_s.split('.').first
		value_hours = ((value.to_d)%8).to_s.split('.').first
		value_mins = ((((value.to_d)%8).to_s.split('.').last).to_d * 0.6).to_s.split('.').first
		if value_mins.to_s.length == 1 && value_mins != 0
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
		if value_mins.to_s.length == 1 && value_mins != 0
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
		if value_mins.to_s.length == 1 && value_mins != 0
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
		if value_mins.to_s.length == 1 && value_mins != 0
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
		if value_mins.to_s.length == 1 && value_mins != 0
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
		if value_mins.to_s.length == 1 && value_mins != 0
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
		if value_mins.to_s.length == 1 && value_mins != 0
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
		if value_mins.to_s.length == 1 && value_mins != 0
			return "#{value_days}.#{value_hours}.#{value_mins}0"
		end
		return "#{value_days}.#{value_hours}.#{value_mins}"
	end

	def self.format_time(to_convert)
# <<<<<<< Updated upstream
# 		time = to_convert/1.hour
		
# 		if time > 1.75
# 			time = 2
# 		elsif time > 1.5
# 			time = 1.75
# 		elsif time > 1.25
# 			time = 1.5
# 		elsif time > 1
# 			time = 1.25
# 		elsif time > 0.75
# 			time = 1.0
# 		elsif time > 0.5
# 			time = 0.75
# 		elsif time > 0.25
# 			time = 0.5
# 		else
# 			time = 0.25
# =======
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
# >>>>>>> Stashed changes
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

end