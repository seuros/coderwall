RSpec.describe TeamsController, type: :routing do
  describe 'routing' do

    it 'routes to #edit with ' do
      expect(get('/team_admin/1/edit')).to route_to(controller: 'team_admin', action: 'edit', id: 1)
    end

  end
end
