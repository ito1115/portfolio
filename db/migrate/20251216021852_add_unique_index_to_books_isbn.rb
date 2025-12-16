class AddUniqueIndexToBooksIsbn < ActiveRecord::Migration[8.0]
  def change
    # 1. まず既存の空文字列をnullに変換
    reversible do |dir|
      dir.up do
        execute "UPDATE books SET isbn = NULL WHERE isbn = ''"
      end
    end

    # 2. ISBNにユニーク制約を追加(PostgreSQLのユニーク制約はデフォルトでnullを許容)
    add_index :books, :isbn, unique: true
  end
end
