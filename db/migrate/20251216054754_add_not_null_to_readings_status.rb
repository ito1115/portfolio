class AddNotNullToReadingsStatus < ActiveRecord::Migration[8.0]
  def change
    change_column_null :readings, :status, false
  end
end
