include FileUtils
class ReportsController < ApplicationController
	def index
		@attendances = Attendance.all
		@requests = Request.all
		respond_to do |format|
			format.html
			format.xls { send_data @attendances.to_csv }
		end
	end

	# def zip
	# 	@names = Attendance.find_by_sql("SELECT name FROM attendances")
	# 	zipfile.get_output_stream("#{user.name}.csv") { |f| 
	# 		f.puts(user.to_csv) 
	# 	}
	# end

	def new
	end

  	def import 
  		Attendance.import(params[:biometrics], params[:falco])
  		Request.import(params[:file])
   		redirect_to reports_path, notice: 'Files Imported!' 
   		#Attendance.destroy_all
	end
end
