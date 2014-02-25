class AddIndexesToRulesAndGroups < ActiveRecord::Migration
  def change
    add_index :groups, :full_url
    add_index :rules, :url
  end
end
