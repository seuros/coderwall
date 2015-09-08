class TeamMembersController < ApplicationController
  before_action :set_team,:set_member

  def destroy
    if @member.remove
      @result = 'This user has been removed in the team.'
    else
      @result = 'Error : This user has not been removed in the team.'
    end
    render 'respond'
  end

  def approve_join
    if @member.approve_join
      @result= 'This user has been approved in the team.'
    else
      @result= 'Error : This user has not been approved in the team.'
    end
    render 'respond'
  end

  def deny_join
    if @member.deny_join
      @result = 'This user has been denied in the team.'
    else
      @result = 'Error : This user has not been denied in the team.'
    end
    render 'respond'
  end

  private
    def set_team
      @team = Team.find(params[:team_id])
      required_team_admin!(@team)
    end

    def self_removal?
     current_user.id == params[:id]
    end

    def set_member
      @member=@team.members.find(params[:member_id])
    end
end
