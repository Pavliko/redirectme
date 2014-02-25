class ChangeUserIdToGroupIdInRule < ActiveRecord::Migration
  def change
    rename_column :rules, :user_id, :group_id
  end
end
