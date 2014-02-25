class AddRenameSlugToCategoryInGroups < ActiveRecord::Migration
  def change
    rename_column :groups, :slug, :category
  end
end
