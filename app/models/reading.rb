# frozen_string_literal: true

class Reading < ApplicationRecord
  belongs_to :user
  belongs_to :book
  belongs_to :purchase_medium, optional: true

  enum :status, {
    wish: 0,             # 気になる
    tsundoku: 1,         # 積読
    completed: 2         # 積読卒業
  }

  validates :status, presence: true

  # 熟成度ランクを計算（積読状態の場合のみ）
  def aging_display
    return nil unless tsundoku? && tsundoku_date.present?

    days = (Date.current - tsundoku_date).to_i

    case days
    when 0...7        then :fresh      # 1週間未満
    when 7...90       then :maturing   # 1週間〜3カ月
    when 90...365     then :aged       # 3カ月〜1年
    when 365...1095   then :vintage    # 1年〜3年
    when 1095...1825  then :premium    # 3年〜5年
    else                   :legendary  # 5年以上
    end
  end

  # 熟成度をアイコン付きバッジで表示
  def maturity_badge_with_icon
    return nil unless aging_display

    config = {
      fresh: { icon: '📚', label: '新鮮' },
      maturing: { icon: '🍷', label: '熟成中' },
      aged: { icon: '🏺', label: '熟成済み' },
      vintage: { icon: '💎', label: 'ヴィンテージ' },
      premium: { icon: '👑', label: 'プレミアム' },
      legendary: { icon: '⭐', label: '伝説級' }
    }

    "#{config[aging_display][:icon]} #{config[aging_display][:label]}"
  end

  # 熟成日数を取得
  def maturity_days
    return nil unless tsundoku? && tsundoku_date.present?

    (Date.current - tsundoku_date).to_i
  end
end
