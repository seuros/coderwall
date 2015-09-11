RSpec.describe TeamJobsController, type: :routing do
  describe 'routing' do

    it 'routes to #show with  job id' do
      expect(get('/team/coderwall/job/666')).to route_to(controller: 'team_jobs', action: 'show', slug: 'coderwall', job_id: '666')
    end
  end
end
