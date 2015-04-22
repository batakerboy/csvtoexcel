include FileUtils
class ReportsController < ApplicationController
	def index
	end

	def new
	end

  	def import     
  		Report.import(params[:file])
   		redirect_to root_url, notice: "Products imported."   
	end 
end
