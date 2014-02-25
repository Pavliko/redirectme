class AddHitCountAndHitLimitToRule < ActiveRecord::Migration
  def change
    add_column :rules, :hit_count, :integer, default: 0
    add_column :rules, :hit_limit, :integer
  end
end
