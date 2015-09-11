RSpec.describe TeamsController, type: :routing do
  describe 'routing' do
    it 'routes to #show' do
      expect(get('/team/coderwall')).to route_to(controller: 'teams', action: 'show', slug: 'coderwall')
    end
  end
end
