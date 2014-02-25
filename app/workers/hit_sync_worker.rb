class HitSyncWorker
  include Sidekiq::Worker

  def perform(group_url, rule_url)
    hit_count = Rails.cache.increment "rule_hit_count:#{group_url}:#{rule_url}"
    group = Group.where(full_url: group_url).first
    group.rules.where(url: rule_url).update_all(hit_count: hit_count) if group
  end
end
