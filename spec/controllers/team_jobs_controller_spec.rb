require 'rails_helper'

RSpec.describe TeamJobsController, :type => :controller do
  let(:current_user) { Fabricate(:user) }
  let(:team) { Fabricate(:team) }

  before { controller.send :sign_in, current_user }

  let(:opportunity) { Fabricate(:opportunity) }

  describe 'GET #show' do
    before do
      url = 'http://maps.googleapis.com/maps/api/geocode/json?address=San%20Francisco,%20CA&language=en&sensor=false'
      @body ||= File.read(File.join(Rails.root, 'spec', 'fixtures', 'google_maps.json'))
      stub_request(:get, url).to_return(body: @body)
    end

    it 'show' do
      get :show, slug: opportunity.team.slug, job_id: opportunity.public_id
      expect(response).to be_success
      expect(response).to render_template('show')
    end

  end
end
