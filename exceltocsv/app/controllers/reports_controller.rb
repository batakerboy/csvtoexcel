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
	  	# File.delete(Rails.root.join('public', 'reports','reports.zip')) if File.exists?(Rails.root.join('public', 'reports','reports.zip'))
	  	File.delete(Rails.root.join('public', 'reports','DTRSUMMARY.xlsx')) if File.exists?(Rails.root.join('public', 'reports','DTRSUMMARY.xlsx'))

		zip = @report.create_zip unless (!@report.name.nil? && File.exists?(Rails.root.join('public', 'reports', @report.name)))
	 	send_file(Rails.root.join('public', 'reports', @report.name), type: 'application/zip', filename: @report.name)
	end								

	def create
		@report = Report.new

		iEMS_path = Rails.root.join('public', 'uploads', 'iEMS.csv')
	  	biometrics_path = Rails.root.join('public', 'uploads','biometrics.csv')
	  	falco_path = Rails.root.join('public', 'uploads','falco.txt')

	  	Request.import(iEMS_path) if File.exists?(iEMS_path)
	  	Attendance.import(biometrics_path) if File.exists?(biometrics_path)
	  	Attendance.import(falco_path) if File.exists?(falco_path)

	  	token = File.open(Rails.root.join('public', 'uploads', 'iEMS.csv'), &:readline).split(',')
	  	@report.date_start = token[1].to_date
	  	@report.date_end = token[3].to_date

	  	File.delete(iEMS_path) if File.exists?(iEMS_path)
	  	File.delete(biometrics_path) if File.exists?(biometrics_path)
	  	File.delete(falco_path) if File.exists?(falco_path)

	  	# @report.name = "DTR-#{@report.id} for #{@report.date_start.strftime('%B %e, %Y')} to #{@report.date_end.strftime('%B %e, %Y')}.zip"

	  	if @report.save
	  		redirect_to report_path(@report), notice:'SUCCESS:Report Generated'
	  	else
	  		render 'index', notice:'FAILED:Generating of reports failed!'
	  	end
	end

	def show
		@report = Report.find(params[:id])
		# Report.update(@report.id, name: "DTR-#{@report.id} for #{@report.date_start.strftime('%B %e, %Y')} to #{@report.date_end.strftime('%B %e, %Y')}.zip") if @report.name.nil?
		@date = @report.date_start
		@cut_off_date = '2015-04-01'.to_date
		@empid = params[:get]

		if "#{@empid['employee_id']}" == ""
			@employees = Employee.all.order(last_name: :asc, first_name: :asc)
			# @employees = Employee.where(last_name: "Balingit")
		else
			@employees = Employee.where(id: "#{@empid['employee_id']}")
		end
		# puts "=========================================="
		# puts "=========================================="
		# puts "=========================================="
		# puts "=========================================="
		# puts "=========================================="
		# puts "#{@empid['employee_id'] == ""}"
		# puts "=========================================="
		# puts "=========================================="
		# puts "=========================================="
		# puts "=========================================="
		# puts "=========================================="
	end

  	def import
  		post = Report.save(params[:biometrics], params[:falco], params[:iEMS])	
   		redirect_to new_report_path(step: params[:step]) 
	end

	def delete_all_records
		Employee.delete_all
		Request.delete_all
		Attendance.delete_all
		Report.delete_all
		redirect_to root_path
	end

	private
	def report_params
		params.require(:report).permit(:date_start, :date_end)
	end
end
