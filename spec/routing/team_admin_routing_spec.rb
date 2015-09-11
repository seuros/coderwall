RSpec.describe TeamAdminController, type: :routing do
  describe 'routing' do
    it 'routes to #edit with ' do
      expect(get('/team_admin/11/edit')).to route_to(controller: 'team_admin', action: 'edit', id: '11')
    end

  end
end
