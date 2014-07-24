require 'rails_helper'

RSpec.describe Protip::SearchWrapper do
  # before(:all) { Protip.__elasticsearch__.refresh_index! }
  let!(:protip) { Fabricate(:protip, user: Fabricate(:user)) }
  it 'provides a consistence api to a protip' do
    wrapper = Protip::SearchWrapper.new(protip)
    expect(wrapper.user.username).to eq(protip.user.username)
    expect(wrapper.user.profile_url).to eq(protip.user.avatar_url)
    expect(wrapper.upvotes).to eq(protip.upvotes)
    expect(wrapper.topics).to eq(protip.topics)
    expect(wrapper.only_link?).to eq(protip.only_link?)
    expect(wrapper.link).to eq(protip.link)
    expect(wrapper.title).to eq(protip.title)
    expect(wrapper.to_s).to eq(protip.public_id)
    expect(wrapper.public_id).to eq(protip.public_id)
  end

  xit 'handles link only protips' do
    link_protip = Fabricate(:protip, body: 'http://google.com', user: Fabricate(:user))
    result = Protip.search_by_string(link_protip.title).results.first
    wrapper = Protip::SearchWrapper.new(result)
    expect(wrapper.only_link?).to eq(link_protip.only_link?)
    expect(wrapper.link).to eq(link_protip.link)
  end

  it 'provides a consistence api to a protip search result' do
    result = Protip.search_by_string(protip.title).results.first
    wrapper = Protip::SearchWrapper.new(result)
    byebug
    expect(wrapper.user.username).to eq(protip.user.username)
    expect(wrapper.user.profile_url).to eq(protip.user.avatar_url)
    expect(wrapper.upvotes).to eq(protip.upvotes)
    expect(wrapper.topics).to match_array(protip.topics)
    expect(wrapper.only_link?).to eq(protip.only_link?)
    expect(wrapper.link).to eq(protip.link)
    expect(wrapper.title).to eq(protip.title)
    expect(wrapper.to_s).to eq(protip.public_id)
    expect(wrapper.public_id).to eq(protip.public_id)
    expect(wrapper.class.model_name).to eq(Protip.model_name)
  end
end
