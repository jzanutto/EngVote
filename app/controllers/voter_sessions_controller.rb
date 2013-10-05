class VoterSessionsController < ApplicationController
  before_filter :require_no_voter, :only => :destroy
  before_filter :validate_params, :only => :new
  before_filter CASClient::Frameworks::Rails::Filter

  #LOGIN
  def new
  #if voter already exists -> login
    puts session[:cas_extra_attributes]
    @voter = Voter.new
      #filter params
    #@voter.student = params[:isstudent] == "True" #Bool
    #@voter.registered = params[:isregistered] == "True" #Bool
    #@voter.undergrad = params[:isundergrad] == "True" #Bool
    # @voter.sid = params[:sid] #String

    if @voter.save
      flash[:notice] = "Login successful."
    end
    redirect_to :controller => :elections, :action => :index

  end

  #LOGOUT
  def destroy
    #current_voter.destroy
    CASClient::Frameworks::Rails::Filter.logout(self)
    flash[:notice] = "Logout successful. Thank you for using SkuleVote v2 (Waterloo EngSoc Edition). Have a nice day!"
    redirect_to :controller => :elections , :action => :index
  end

  private
    def validate_params
      password = "password" #move to some config file

      #store hash
      hash_given = params[:hash]

      #remove auto-include values and hash from params variable
      params.delete(:action)
      params.delete(:controller)
      params.delete(:hash)

      #valid = hashof((concatofparameters-hash)+password) == hashinparams
      hash_check = Digest::MD5.hexdigest(params.values.to_s+password)
      valid = (hash_check == hash_given)

      if false
        flash[:notice] = "The link you followed was incorrect. Please try again."+hash_check
        redirect_to :controller => :elections, :action => :index
      end
    end

end
