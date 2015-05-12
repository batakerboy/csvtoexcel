class WelcomeController < ApplicationController
  before_filter :authenticate_user, :only => [:index, :setting]
  before_filter :save_login_state, :only => [:login, :login_attempt]
  before_filter :check_if_active, :only => [:index, :setting]

  def index
  end

  def login
  end

  def login_attempt
  	authorized_user = User.authenticate(params[:username], params[:login_password])

  	if authorized_user
      session[:user_id] = authorized_user.id
  	  flash[:notice] = "Wow Welcome again, you logged in as #{authorized_user.username}"
      redirect_to index_path
  	else
  	  flash[:notice] = "Invalid Username or Password"
  	  flash[:color]= "invalid"
  	  render "login"
  	  # redirect_to login_attempt_path	
  	end
  end

  def logout
    session[:user_id] = nil
    redirect_to :action => 'login'
  end

  def setting
  	
  end
end