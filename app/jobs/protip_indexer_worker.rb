class ProtipIndexerWorker
  include Sidekiq::Worker

  sidekiq_options :queue =>  :high

  def perform(protip_id)
    protip = Protip.find(protip_id)
    protip.__elasticsearch__.index_document unless protip.user.banned?
  end
end
