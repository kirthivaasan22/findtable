class CreateRestaurants < ActiveRecord::Migration[6.0]
  def change
    create_table :restaurants, id: false do |t|
      t.string :es_id, null: false, limit: 191
    end
    add_index :restaurants, :es_id, unique: true
  end
end