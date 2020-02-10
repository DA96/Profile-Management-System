class AddIndexOnCreatedAt < ActiveRecord::Migration[5.1]
  def change
  	add_index :users, :created_at
  end
end
