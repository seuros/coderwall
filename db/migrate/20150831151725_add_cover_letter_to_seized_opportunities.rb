class AddCoverLetterToSeizedOpportunities < ActiveRecord::Migration
  def change
    add_column :seized_opportunities, :cover_letter, :text
  end
end
