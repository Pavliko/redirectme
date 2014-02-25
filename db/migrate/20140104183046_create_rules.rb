class CreateRules < ActiveRecord::Migration
  def change
    create_table :rules do |t|
      t.boolean :master
      t.integer :user_id
      t.string :url
      t.string :expression

      t.timestamps
    end
  end
end
