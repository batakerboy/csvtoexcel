class UsersController < ApplicationController
	before_filter :authenticate_user, :only => [:new, :create, :edit, :index, :update]
	before_filter :check_if_admin, :only => [:new, :create, :edit, :index, :update]
	before_filter :check_if_active, :only => [:new, :create, :edit, :index, :update]
 	# before_filter :save_login_state, :only => [:new, :create]

 	def index
 		@users = User.all	
 	end

	def new
		@user = User.new
	end

	def edit
		@user = User.find(params[:id])
	end

	def create
		@user = User.new(user_params)
		if @user.save
			redirect_to users_path
		else
			render 'new'
		end
	end

	def update
		@user = User.find(params[:id])

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
		# User.update(@user.id, is_active: false)
		redirect_to users_path		
	end

	private
	def user_params
		params.require(:user).permit(:first_name, :last_name, :department, :username, :password, :password_confirmation, :is_admin, :is_active)
	end
end
