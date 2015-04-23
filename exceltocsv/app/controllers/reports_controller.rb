include FileUtils
class ReportsController < ApplicationController
	def index
		@attendances = Attendance.order(:name)
		respond_to do |format|
			format.html
			format.xls { send_data @attendances.to_csv }
		end
	end

	def new
	end

  	def import 
  		Report.import(params[:biometrics], params[:falco])
   		redirect_to reports_path, notice: 'Files Imported!' 
	end
end
