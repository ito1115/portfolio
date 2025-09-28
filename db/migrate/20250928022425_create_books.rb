class CreateBooks < ActiveRecord::Migration[7.1]
  def change
    create_table :books do |t|
      t.string :title, null: false
      t.string :author
      t.string :publisher
      t.string :published_date
      t.text :description
      t.string :isbn
      t.string :image_url

      t.timestamps
    end
  end
end
