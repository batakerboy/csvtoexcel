class EmployeesController < ApplicationController
  def index
    @employees = Employee.all
  end

  def new
    @employee = Employee.new
  end

  def create
    @employee = Employee.new(employee_params)
    # @employee.status = "Active"

    if @employee.save
      redirect_to employees_path, notice: "SUCCESS:New Employee Created!"
    else
      redirect_to employees_path, notice: "FAILED:Adding of new employee failed!"
    end
  end

  def edit
    @employee = Employee.find(params[:id])
  end

  def update
    @employee = Employee.find(params[:id])

    if @employee.update(employee_params)
      redirect_to employees_path, notice: "SUCCESS:Update successful!"
    else
      redirect_to employees_path, notice: "FAILED:Update failed!"
    end
  end

  def destroy
    @employee = Employee.find(params[:id])
    @employee.destroy
    redirect_to employees_path
  end

  # def change_status
  #   @employee = Employee.find(params[:id])

  #   if @employee.status == 'Active'
  #     @employee.status = 'Inactive'
  #     redirect_to employees_path, notice: "SUCCESS:#{@employee.last_name}, #{employee.first_name} has been deactivated!"
  #   elsif @employee.status == 'Inactive'
  #     @employee.status = 'Active'
  #     redirect_to employees_path, notice: "SUCCESS:#{@employee.last_name}, #{employee.first_name} has been activated!"
  #   else
  #     redirect_to employees_path, notice: "FAILED:Changing of status has failed!"
  #   end
  # end

  # def deactivate
  #   @employee = Employee.find(params[:id])
  #   @employee.status = 'Inactive'
  # end

  # def activate
  #   @employee = Employee.find(params[:id])
  #   @employee.status = 'Active'
  # end

  def import
    Employee.import(params[:file])
    redirect_to employees_path, notice: 'SUCCESS:Files Imported!'
  end

  private
  def employee_params
    params.require(:employee).permit(:id, :first_name, :last_name, :department, :biometrics_id, :falco_id)
  end
end
