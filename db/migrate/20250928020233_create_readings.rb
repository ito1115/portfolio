class CreateReadings < ActiveRecord::Migration[7.1]
  def change
    create_table :readings do |t|
      t.text :reason
      t.integer :status
      t.date :tsundoku_date
      t.date :wish_date
      t.date :completed_date
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
