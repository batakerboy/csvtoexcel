include FileUtils
class ReportsController < ApplicationController
	def index
		@attendances = Attendance.all
	end

	def new
	end

  	def import     
  		Report.import(params[:biometrics],params[:falco])
   		redirect_to root_url, notice: "Products imported."   
	end 
end
