class AddConstraintsToUser < ActiveRecord::Migration[5.1]
  def change
  	#adding not null constraint
  	change_column_null :users, :name, false
  	change_column_null :users, :email, false
  	change_column_null :users, :phone_no, false
  	change_column_null :users, :password_digest, false

  	add_index :users, :email

  	change_table :users do |t|
  		t.column :status, :integer, default: 0
  	end

  end
end
