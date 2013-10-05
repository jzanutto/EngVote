class ApplicationController < ActionController::Base
  helper :all
  protect_from_forgery

  helper_method :current_voter_session

  def current_voter_session
    return @current_voter_session if defined?(@current_voter_session)
    @current_voter_session = true
  end

  def require_voter
    unless current_voter
      # store_location
      flash[:notice] = "You must be logged in to access this page"
      redirect_to :controller => :elections, :action => :index
      false
    end
  end

  def require_no_voter
    if current_voter
      store_location
      flash[:notice] = "You must be logged out to access this page."
      redirect_to :controller => :elections, :action => :index
      false
    end
  end

  def store_location
    # session[:return_to] = request.request_uri
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

end
