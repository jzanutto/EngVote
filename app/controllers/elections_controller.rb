class ElectionsController < ApplicationController
  before_filter :authenticate, :except => [:index, :vote, :help, :public]
  before_filter :require_no_voter, :only => [:index, :vote]
  before_filter CASClient::Frameworks::Rails::Filter
  # before_filter :validate_eligibility, :only => [:vote]

  def public
    if current_voter
      redirect_to :action => :index
    end
  end

  def index
    # @elections = Election.find(:all, :conditions => {:eligible_year => [current_voter.year, nil, "", 'null'], :eligible_discipline => [current_voter.discipline, nil, "", 'null']})
    @elections = Election.all(:conditions => "(eligible_year IN (#{current_voter.year}, '') OR eligible_year ISNULL) AND (eligible_discipline IN ('#{current_voter.discipline}', '') OR eligible_discipline ISNULL)")
    @elections -= current_voter.elections
  end

  def vote
    @election = Election.find(params[:id])
    @choices = @election.choices.sort_by {rand}

    @ballot = Ballot.new
    @vote = Vote.new

  end

  def admin
    @elections = Election.all
  end

  def help

  end

  def results
    @election = Election.find(params[:id])
  end

  def ballots
    @election = Election.find(params[:id])

    @spoiled = @election.votes.all(:conditions => {:choice_id => 0 })
  end

  def add_choice
    @choice = Choice.new
  end

  def new
    @election = Election.new
    @choice = Choice.new
    @election.choices << @choice
  end

  def edit
    @election = Election.find(params[:id])
  end

  def create
    @method = params[:election][:method]
    params[:election].delete(:method)

    @election = Election.new(params[:election])

    #should be a before_save filter
    case @method
      when "preferential"
        @election.preferential = true
      when "single_choice"
        params[:election][:max_choices] = 1
        @election.preferential = false
      when "multiple_choice"
        @election.preferential = false
      else
        #raise error
    end if false

    if @election.save
      flash[:notice] = 'Election was successfully created.'
      redirect_to(:action => 'admin')
    else
      render :action => "new"
    end
  end

  def update
    @method = params[:election][:method]
    params[:election].delete(:method)

    @election = Election.find(params[:id])

    #should be a before_save filter
    case @method
      when "preferential"
        @election.preferential = true
      when "single_choice"
        params[:election][:max_choices] = 1
        @election.preferential = false
      when "multiple_choice"
        @election.preferential = false
      else
        #raise error
    end

    if @election.update_attributes(params[:election])
      flash[:notice] = 'Election was successfully updated.'
      redirect_to(:action => 'admin')
    else
      render :action => "edit"
    end
  end

  def destroy
    @election = Election.find(params[:id])
    @election.destroy

    flash[:notice] = 'Election was successfully destroyed.'
    redirect_to(:action => 'admin')
  end

  protected

  def authenticate
    authenticate_or_request_with_http_basic { |username, password| username == "admin" && password == "pass" }
  end

  def validate_eligibility
    @election = Election.find(params[:id])
    # note: all conditions must true to be eligible
    v = @voter
    # always
    # checks["hasntvotedyet"] = !v.elections.includes?(@election)
    year = v.year if v.year == @election.eligible_year && @election.eligible_year
    discipline = v.discipline if v.discipline == @election.eligible_discipline && @election.eligible_discipline && @election.eligible_discipline.length > 0
    checks = {
      :student => v.student,
      :registered => v.registered,
      :undergrad => v.undergrad, #must be true
      # add department of engineering
      # add special eligibility via whitelist/blacklist
      :year => year,
      :discipline => discipline
      #checks["pey"] = v.pey
    }
    # if a check fails, send a notice to the user
    if checks.value?(false)
      flash[:notice] = "You are not eligible to vote in this election."
      redirect_to :controller => :elections, :action => :index
    end
  end

end
