include FileUtils
require 'csv'
require 'pathname'
require 'rubygems'
require 'zip'
require 'axlsx'
class ReportsController < ApplicationController
	before_filter :authenticate_user, :only => [:index, :new, :download_zip, :create, :show, :import, :delete_all_records]
  	before_filter :check_if_active, :only => [:index, :new, :download_zip, :create, :show, :import, :delete_all_records]

	def index
		@reports = Report.all.order(date_start: :asc)
	end

	def new
		@report = Report.new
	end

	def download_zip
		@report = Report.find(params[:report_id])
	  	File.delete(Rails.root.join('public', 'reports','DTRSUMMARY.xlsx')) if File.exists?(Rails.root.join('public', 'reports','DTRSUMMARY.xlsx'))

		zip = @report.create_zip unless (!@report.name.nil? && File.exists?(Rails.root.join('public', 'reports', @report.name)))
	 	send_file(Rails.root.join('public', 'reports', @report.name), type: 'application/zip', filename: @report.name)
	end								

	def create
		@report = Report.new

		iEMS_path = Rails.root.join('public', 'uploads', 'iEMS.csv')
	  	biometrics_path = Rails.root.join('public', 'uploads','biometrics.csv')
	  	falco_path = Rails.root.join('public', 'uploads','falco.txt')

	  	begin
	  		raise "File not uploaded for iEMS." unless File.exists?(iEMS_path)
	  		raise "File not uploaded for Biometrics." unless File.exists?(biometrics_path)
	  		raise "File not uploaded for Falco." unless File.exists?(falco_path)

		  	token = File.open(biometrics_path, &:readline).split(/,(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)/).flatten.compact
		  	raise 'The file uploaded for Biometrics is wrong or has been tampered' if token.nil? || (token[0] != 'Mustard Seed' || (token[62].nil? && token[53].nil?))
			
			token = File.open(iEMS_path, &:readline).split(',')
			raise 'The file uploaded for iEMS is wrong or has been tampered!' if token[0].tr('"', '') != 'FROM'

		  	token = File.open(falco_path, &:readline).gsub(/\s+/m, ' ').split(" ")
		  	raise 'The file uploaded for Falco is wrong or has been tampered' if token.length != 0
		
		  	raise 'The date range in at least one of the files are not the same with the others!' if !check_date_range

			@report.employee_ids = Request.import(iEMS_path) if File.exists?(iEMS_path)
		  	Attendance.import(biometrics_path) if File.exists?(biometrics_path)
			Attendance.import(falco_path) if File.exists?(falco_path)
			
			token = File.open(iEMS_path, &:readline).split(',')
		  	@report.date_end = token[3].tr('"', '').to_date
			@report.date_start = token[1].tr('"', '').to_date


		  	if @report.save
	  			redirect_to report_path(@report)
		  	else
		  		render 'index'
		  	end
		rescue Exception => e
			puts "========================"
			puts e.message
			puts "========================"
			puts token
			puts "========================"
			unless @path.nil?
				redirect_to @path, notice: e.message
			else
				redirect_to new_report_path(step: 1), notice: e.message
			end
	  	end

		File.delete(iEMS_path) if File.exists?(iEMS_path)
	  	File.delete(biometrics_path) if File.exists?(biometrics_path)
	  	File.delete(falco_path) if File.exists?(falco_path)
	end

	def show
		@report = Report.find(params[:id])
		@date = @report.date_start
		@cut_off_date = '2015-04-01'.to_date
		@empid = params[:get]

		ids = @report.employee_ids.tr('"[]','').split(",")
		@all_employees = Employee.find(ids).sort_by{|i| [i.last_name, i.first_name, i.department]}
		if @empid.nil? || @empid['employee_id'] == "All"
			@employees = @all_employees	
		else
			@employees = Employee.where(id: @empid['employee_id'])
		end

	end

  	def import
  		begin
  			# @path = new_report_path(step: 1)

  			unless params[:biometrics].nil?
  				token = File.open(params[:biometrics]['report'].path, &:readline).split(/,(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)/).flatten.compact
  				if token.nil? || (token[0] != 'Mustard Seed' || (token[62].nil? && token[53].nil?))
  					@path = new_report_path(step: 1)
  					raise 'The file uploaded for Biometrics is wrong or has been tampered' 
  				end
  			end

  			unless params[:iEMS].nil?
  				token = File.open(params[:iEMS]['report'].path, &:readline).split(',')
  				if token[0].tr('"', '') != 'FROM'
  					@path = new_report_path(step: 3)
					raise 'The file uploaded for iEMS is wrong or has been tampered!' 
  				end
  			end

  			unless params[:falco].nil?
			  	token = File.open(params[:falco]['report'].path, &:readline).gsub(/\s+/m, ' ').split(" ")
			  	if token.length != 0
			  		@path = new_report_path(step: 2)
			  		raise 'The file uploaded for Falco is wrong or has been tampered' 
			  	end
  			end

	  		post = Report.save(params[:biometrics], params[:falco], params[:iEMS])	
	   		redirect_to new_report_path(step: params[:step]) 

  			rescue Exception => e
				puts "========================"
				puts e.message
				puts "========================"
				puts token
				puts "========================"
				unless @path.nil?
					redirect_to @path, notice: e.message
				else
					redirect_to new_report_path(step: 1), notice: e.message
				end
  			
  		end
  		
	end

	def delete_all_records
		Employee.delete_all
		Request.delete_all
		Attendance.delete_all
		Report.delete_all
		redirect_to root_path
	end

	def check_date_range
		iEMS_path = Rails.root.join('public', 'uploads', 'iEMS.csv')
	  	biometrics_path = Rails.root.join('public', 'uploads','biometrics.csv')
	  	falco_path = Rails.root.join('public', 'uploads','falco.txt')

	  	token = File.open(iEMS_path, &:readline).split(',')
		iEMS_date_start = token[1].tr('"', '').to_date		
	  	iEMS_date_end = token[3].tr('"', '').to_date

	  	token = File.open(biometrics_path, &:readline).split(/,(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)/).flatten.compact
		temp = token[4].tr('"', '').split(' ')
		bio_date_start = "#{temp[1]} #{temp[2]} #{temp[3]}".to_date
		bio_date_end = "#{temp[5]} #{temp[6]} #{temp[7]}".to_date

		falco_date_start = Date.today
		falco_date_end = Date.today

		file = File.open(falco_path, 'r:ISO-8859-1')
		file.each_with_index do |row|
			token = row.gsub(/\s+/m, ' ').split(" ")
			if token[0] == 'Date'
				falco_date_start = token[3].to_date
				falco_date_end = token[6].to_date
				break
			end
		end

		equal = true

		equal = false if iEMS_date_start != bio_date_start
		equal = false if iEMS_date_start != falco_date_start
		equal = false if falco_date_start != bio_date_start

		return equal
	end

	private
	def report_params
		params.require(:report).permit(:date_start, :date_end)
	end
end
