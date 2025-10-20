class CreatePurchaseMedia < ActiveRecord::Migration[7.1]
  def change
    create_table :purchase_media do |t|
      t.string :name, null: false       # 媒体名（識別子）
      t.string :category                # カテゴリ（physical/digital/other）

      t.timestamps
    end

    add_index :purchase_media, :name, unique: true
  end
end
