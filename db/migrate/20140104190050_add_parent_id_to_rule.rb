class AddParentIdToRule < ActiveRecord::Migration
  def change
    add_column :rules, :parent_id, :integer
  end
end
