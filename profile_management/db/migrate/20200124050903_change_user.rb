class ChangeUser < ActiveRecord::Migration[5.1]
  def change
  	change_table :users do |t|
  		t.string :password_digest
  		rename_column :users, :Name, :name
  		rename_column :users, :Email, :email
  		rename_column :users, :Phone_no, :phone_no
  		#t.boolean :user_status
  	end
  end
end
