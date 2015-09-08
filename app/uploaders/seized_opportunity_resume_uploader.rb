class SeizedOpportunityResumeUploader < CoderwallUploader

  def store_dir
    "uploads/opportunities/applicants/#{model.user_id}/resume/#{model.id}"
  end

  def extension_white_list
    %w(pdf doc docx odt txt jpg jpeg png)
  end
end
