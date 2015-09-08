class ResumeUploadsController < ApplicationController
  before_action :access_required

  # POST /resume_uploads
  def create
    if current_user.update_attributes(resume: params[:resume])
      flash[:notice]= 'Your resume has been updated.'
    else
      flash[:error]= 'There was an error updating your resume.'
    end
    redirect_to :back, :anchor => params[:section]
  end

  # DELETE /resume_uploads
  def destroy
    current_user.update_attributes(remove_resume: true)
  end

end
