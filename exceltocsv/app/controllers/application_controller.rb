class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  protected 
  def authenticate_user
    if session[:user_id]
       # set current user object to @current_user object variable
      @current_user = User.find session[:user_id]
      return true	
    else
      redirect_to(:controller => 'welcome', :action => 'login')
      return false
    end
  end
  
  def save_login_state
    if session[:user_id]
      redirect_to(:controller => 'welcome', :action => 'index')
      return false
    else
      return true
    end
  end

  def check_if_admin
    if session[:user_id]
      if @current_user.is_admin
        return true
      else
        redirect_to index_path
        return false
      end
    else
        redirect_to index_path
        return false
    end
  end

  def check_if_active
    if session[:user_id]
      if @current_user.is_active
        return true
      else
        redirect_to logout_path
        return false
      end
    else
      redirect_to logout_path
      return false
    end
  end
end
