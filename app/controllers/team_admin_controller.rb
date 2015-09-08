class TeamAdminController < ApplicationController
  before_action :set_team
  layout 'coderwallv2'

  def edit
    @team.locations.build unless @team.locations.any?
  end

  def update
    if @team.update_attributes(team_params)
      flash[:notice] = 'Your team has been updated !'
    else
      flash[:error] = 'There are an issue for update, please try again or contact support@coderwall.com'
    end
    redirect_to(:action => :edit, :id => @team.id, :anchor => params[:section])
  end

  private

  def set_team
    @team = Team.find(params[:id])
    required_team_admin!(@team)
  end

  def team_params
    params.require(:team).permit(
        :name,
        :about,
        :branding,
        :avatar,
        :preview_code,
        :highlight_tags,
        :premium,
        :valid_jobs,
        :hide_from_featured,
        :website,
        :github,
        :facebook,
        :twitter,
        :headline,
        :big_quote,
        :big_image,
        :youtube_url,
        :our_challenge,
        :your_impact,
        :benefit_name_1,
        :benefit_description_1,
        :benefit_name_2,
        :benefit_description_2,
        :benefit_name_3,
        :benefit_description_3,
        :organization_way_name,
        :organization_way,
        :organization_way_photo,
        {:office_photos=>[]},
        :stack_list,
        :reason_name_1,
        :reason_description_1,
        :reason_name_2,
        :reason_description_2,
        :reason_name_3,
        :reason_description_3,
        :why_work_image,
        :blog_feed,
        {:interview_steps=>[]},
        locations_attributes: [:id, :name, :description, :address, :_destroy]
    )
  end
end
