class CreateUsers < ActiveRecord::Migration[5.1]
  def change
  	#add_column :users, :user_type, :usr_type
    create_table :users do |t|
      t.string :name
      t.string :email
      t.integer :phone_no
      t.string :password_digest
      #t.boolean :user_status
      #t.enum [:Broker, :Buyer, :Owner] :user_type
      #add_column :users, :user_type, :usr_type

      t.timestamps
    end
  end
end
