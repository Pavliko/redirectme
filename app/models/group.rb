class Group < ActiveRecord::Base
  has_many :rules, dependent: :delete_all
  belongs_to :user

  accepts_nested_attributes_for :rules

  before_save :set_full_url, :generate_cache

  validates :full_url, uniqueness: true

  def generate_cache
    Rails.cache.delete cache_key if full_url.present?
    Rails.cache.write cache_key, rules_proc, raw: true
  end

  def name_or_generate count
    name || I18n.t('group_default_name', id: count)
  end

  def cache_key
    "group:#{full_url}"
  end

  def self.cache_key url
    "group:#{url}"
  end

  def service_domain?
    domain.in? $GLOBAL[:service_hosts]
  end

  def rules_proc
    acum = 0
    expression = rules.map do |rule|
      acum += rule.expression.to_f
      ["random < #{acum}", "'#{rule.url}'"].join(' && ')
    end

    "-> (random, data) {#{[ expression, "'#{rules.first.url}'" ].join(' || ')}}"
  end
end
