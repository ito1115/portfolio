class AddPurchaseMediumToReadings < ActiveRecord::Migration[7.1]
  def change
    add_reference :readings, :purchase_medium, null: true, foreign_key: true
  end
end
