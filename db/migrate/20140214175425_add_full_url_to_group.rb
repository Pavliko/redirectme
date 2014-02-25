class AddFullUrlToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :full_url, :string
  end
end
