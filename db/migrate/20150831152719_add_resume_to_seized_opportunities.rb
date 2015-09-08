class AddResumeToSeizedOpportunities < ActiveRecord::Migration
  def change
    add_column :seized_opportunities, :resume, :string
  end
end
