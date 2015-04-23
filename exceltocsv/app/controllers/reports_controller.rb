include FileUtils
class ReportsController < ApplicationController
	def index
		@attendances = Attendance.order(:name)
		respond_to do |format|
			format.html
			# format.csv { send_data @attendances.to_csv }
			format.xls { send_data @attendances.to_csv(col_sep: "\t") }
		end
	end

	def new
	end

  	def import 
  		Report.import(params[:biometrics], params[:falco])
   		redirect_to root_url, notice: 'Files Imported!' 
	end
end
