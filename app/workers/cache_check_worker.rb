class CacheCheckWorker
  include Sidekiq::Worker

  def perform(group_url)
    group = Group.where(full_url: group_url).first.try(:generate_cache)
  end
end
