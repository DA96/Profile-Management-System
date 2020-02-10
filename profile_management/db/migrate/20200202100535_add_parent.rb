class AddParent < ActiveRecord::Migration[5.1]
  def change
  	change_table :users do |t|
      t.references :parent
    end
  end
end
