class UpdateReadingStatusToThreeStages < ActiveRecord::Migration[7.1]
  def up
    # 既存の reading (2) を tsundoku (1) に統合
    Reading.where(status: 2).update_all(status: 1)

    # 既存の completed (3) を新しい completed (2) に更新
    Reading.where(status: 3).update_all(status: 2)
  end

  def down
    # ロールバック時の処理（元に戻すのは難しいので警告を出す）
    raise ActiveRecord::IrreversibleMigration, "Cannot revert this migration as original reading status data would be lost"
  end
end
