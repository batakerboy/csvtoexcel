class UsersController < ApplicationController
	before_filter :authenticate_user, :only => [:new, :create, :edit, :index, :update, :profile]
	before_filter :check_if_admin, :only => [:new, :create, :edit, :index]
	before_filter :check_if_active, :only => [:new, :create, :edit, :index, :update]
 	# before_filter :save_login_state, :only => [:new, :create]

 	def index
 		@users = User.all.order(last_name: :asc, first_name: :asc, department: :asc)	
 	end

	def new
		@user = User.new

		if params[:create_admin] == 'true'
			@create_admin = true
		else
			@create_admin = false
		end
	end

	def edit
		@user = User.find(params[:id])

		if params[:create_admin] == 'true'
			@create_admin = true
		else
			@create_admin = false
		end
	end

	def profile
		@user = User.find(params[:user_id])
	end

	def create
		@user = User.new(user_params)

		@create_admin = params[:create_admin]

		if @user.save
			# UserMailer.account_created(@user, params[:password]).deliver_later
			# @user.clear_password
			redirect_to users_path
		else
			render 'new'
		end
	end

	def update
		@user = User.find(params[:id])

		@create_admin = params[:create_admin]

		if @user.update(user_params)
			redirect_to users_path
		else
			render 'edit'
		end
	end

	def activate
		@user = User.find(params[:user_id])
		@user.activate
		redirect_to users_path
	end

	def deactivate
		@user = User.find(params[:user_id])
		@user.deactivate
		redirect_to users_path		
	end

	private
	def user_params
		params.require(:user).permit(:first_name, :last_name, :department, :username, :password, :password_confirmation, :email, :is_admin, :is_active)
	end
end
