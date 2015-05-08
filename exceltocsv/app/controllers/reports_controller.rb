include FileUtils
require 'csv'
require 'pathname'
require 'rubygems'
require 'zip'
require 'axlsx'
class ReportsController < ApplicationController

	def index
		@reports = Report.all.order(date_start: :asc)
	end

	def new
		@report = Report.new
	end

	def download_zip
		@report = Report.find(params[:report_id])
	  	File.delete(Rails.root.join('public', 'reports','reports.zip')) if File.exists?(Rails.root.join('public', 'reports','reports.zip'))
	  	File.delete(Rails.root.join('public', 'reports','DTRSUMMARY.xlsx')) if File.exists?(Rails.root.join('public', 'reports','DTRSUMMARY.xlsx'))

		zip = @report.create_zip
	 	send_file(Rails.root.join('public', 'reports', 'reports.zip'), type: 'application/zip', filename: "DTR for #{@report.date_start} to #{@report.date_end}.zip")
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

	  	if @report.save
	  		redirect_to report_path(@report), notice:'SUCCESS:Report Generated'
	  	else
	  		render 'index', notice:'FAILED:Generating of reports failed!'
	  	end
	end

	def show
		@report = Report.find(params[:id])
		@date = @report.date_start
		@cut_off_date = '2015-04-01'.to_date
		@employees = Employee.all.order(last_name: :asc, first_name: :asc)		
	end

  	def import
  		post = Report.save(params[:biometrics], params[:falco], params[:iEMS])	
   		redirect_to new_report_path(step: params[:step]), notice:'SUCCESS:File Imported!' 
	end

	private
	def report_params
		params.require(:report).permit(:date_start, :date_end)
	end
end
