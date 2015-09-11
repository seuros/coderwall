require 'spec_helper'

RSpec.describe TeamsController, type: :controller do
  let(:current_user) { Fabricate(:user) }
  let(:team) { Fabricate(:team) }

  before { controller.send :sign_in, current_user }

  it 'allows user to follow team' do
    post :follow, id: team.id, format: :js

    expect(response).to be_success
    current_user.reload
    expect(current_user.following_team?(team)).to eq(true)
  end

  it 'allows user to stop follow team' do
    current_user.follow_team!(team)
    current_user.reload
    expect(current_user.following_team?(team)).to eq(true)
    post :follow, id: team.id
    current_user.reload
    expect(current_user.following_team?(team)).to eq(false)
  end

  describe 'GET #index' do
    it 'responds successfully with an HTTP 200 status code' do
      get :index
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET #show' do
    before do
      url = 'http://maps.googleapis.com/maps/api/geocode/json?address=San%20Francisco,%20CA&language=en&sensor=false'
      @body ||= File.read(File.join(Rails.root, 'spec', 'fixtures', 'google_maps.json'))
      stub_request(:get, url).to_return(body: @body)
    end

    it 'responds successfully with an HTTP 200 status code' do
      team = Fabricate(:team) do
        name FFaker::Company.name
        slug FFaker::Internet.user_name
      end
      get :show, slug: team.slug
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    context 'when searching by an out of bounds or non-integer id' do
      it 'should render 404' do
        get :show, id: '54209333547a9e5'
        expect(response).to have_http_status(404)
      end
    end
  end

  describe '#create' do
    let(:team) { Fabricate.build(:team, name: 'team_name') }

    before do
      allow(Team).to receive(:with_similar_names).and_return([])
    end

    context 'a team is selected from a list of similar teams' do
      it 'renders a template with a choice of tariff plans when user joins and existing team' do
        allow(Team).to receive(:where).and_return(%w(team_1 team_2))
        post :create, team: { join_team: 'true', slug: 'team_name' }, format: :js

        expect(assigns[:team]).to eq('team_1')
        expect(response).to render_template('create')
      end

      it 'renders a template with a choice of tariff plans if user picks supplied team name' do
        post :create, team: { name: 'team_name' }, format: :js
        expect(response).to render_template('create')
      end
    end

    context 'a team does not exist' do
      let(:response) { post :create, team: { name: 'team_name' }, format: :js }

      before do
        allow(Team).to receive(:new).and_return(team)
        allow(team).to receive(:save).and_return(true)
        allow(team).to receive(:add_user).and_return(true)
      end

      it 'creates a new team' do
        expect(team).to receive(:save)
        response
      end

      it 'adds current user to the team' do
        expect(team).to receive(:add_user).with(current_user, 'active', 'admin')
        response
      end

      it 'records an event "created team"' do
        expect(controller).to receive(:record_event).with('created team')
        response
      end

      it 'renders template with option to join' do
        expect(response).to be_success
        expect(response).to render_template('create')
        expect(flash[:notice]).to include('Successfully created a team team_name')
      end

      it 'renders failure notice' do
        allow(team).to receive(:save).and_return(false)
        response
        expect(flash[:error]).to include('There was an error in creating a team team_name')
      end
    end

    context 'a team with similar name already exists' do
      before do
        allow(Team).to receive(:new).and_return(team)
        allow(Team).to receive(:with_similar_names).and_return([team])
      end

      it 'renders a template with a list of similar teams' do
        post :create, team: { name: 'team_name', show_similar: 'true' }, format: :js

        expect(assigns[:new_team_name]).to eq('team_name')
        expect(response).to render_template('similar_teams')
      end
    end
  end

end
