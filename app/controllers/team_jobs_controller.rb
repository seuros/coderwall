class TeamJobsController < ApplicationController
  layout 'coderwallv2'
  before_action :set_team

  def index
    @jobs = @team.jobs
  end

  def show
    @job = @team.jobs.find_by_public_id(params[:job_id])
    @other_jobs = @team.jobs.reject { |job| job.id == @job.id } unless @job.nil?

    unless is_admin?
      viewing_user.track_opportunity_view!(@job) if viewing_user
      @job.viewed_by(viewing_user || session_id)
    end

  end

  def apply
    redirect_to_signup_if_unauthenticated(request.referer, 'You must login/signup to apply for an opportunity') do

      @job = @team.jobs.find_by_public_id(params[:job_id])

      if request.post?
        opportunity=UserOpportunityService.new(@job)
        if opportunity.apply(current_user,params[:seized_opportunity][:cover_letter],params[:seized_opportunity][:resume])
          NotifierMailer.new_applicant(current_user.id, @job.id).deliver!
          record_event('applied to job', job_public_id: @job.public_id, 'job team' => @job.team.slug)
          redirect_to teamname_job_path(slug: @team.slug, job_id: @job.public_id), notice: 'Your resume has been submitted for this job!'
        else
          flash[:error] = 'There are an issue for apply, please try again or contact support@coderwall.com'
        end
      end
      @seized_opportunity = SeizedOpportunity.new
    end
  end

  def set_team
    @team = Team.find_by_slug!(params[:slug])
  end
end
