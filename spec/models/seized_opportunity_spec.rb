# == Schema Information
#
# Table name: seized_opportunities
#
#  id             :integer          not null, primary key
#  opportunity_id :integer
#  user_id        :integer
#  created_at     :datetime
#  updated_at     :datetime
#  cover_letter   :text
#  resume         :string(255)
#

require 'spec_helper'

RSpec.describe SeizedOpportunity, type: :model do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:opportunity) }
end
