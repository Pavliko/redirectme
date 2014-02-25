class Rule < ActiveRecord::Base
  belongs_to :group
  belongs_to :parent, class_name: 'Rule', foreign_key: :parent_id
  has_many :childs, class_name: 'Rule', foreign_key: :parent_id, dependent: :nullify

  def generate_cache_count
    Rails.cache.write count_cache_key, 0, raw: true, unless_exist: true
    count_cache_key
  end

  def count_cache_key
    "rule_hit_count:#{group.full_url}:#{url}"
  end

  def reset_cached_count
    Rails.cache.write count_cache_key, 0, raw: true
  end
end
