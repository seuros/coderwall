class TeamProtips
  def initialize(team)
    @team=team
  end

  def members_ids
    @members_ids ||= @team.members.active.pluck(:user_id)
  end

  def protips
    Protip.where(:user_id=>members_ids)
  end

  def has_protips?
    protips.count>0
  end
end