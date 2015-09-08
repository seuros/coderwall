class UserOpportunityService

  def initialize(job)
    @job=job
  end

  def apply(user,cover_letter='',resume)

    resume=user.resume unless resume.present?

    return false  if(!@job.accepts_applications? || !resume.present?)

    @job.seized_opportunities.create(user_id: user.id, cover_letter: cover_letter, resume: resume)

  end

end