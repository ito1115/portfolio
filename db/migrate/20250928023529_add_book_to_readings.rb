class AddBookToReadings < ActiveRecord::Migration[7.1]
  def change
    add_reference :readings, :book, null: false, foreign_key: true
  end
end
