# frozen_string_literal: true

require 'mini_magick'

# 動的OGP画像生成サービス
class OgpImageGenerator
  IMAGE_WIDTH = 1200
  IMAGE_HEIGHT = 630

  # テキスト情報の設定
  TEXT_LEFT = 80
  TITLE_TOP = 150
  AUTHOR_TOP = 230
  STATUS_TOP = 290
  REASON_TOP = 350

  # フォント設定
  FONT_PATH = Rails.root.join('app/assets/fonts/NotoSansJP-VariableFont_wght.ttf').to_s
  TITLE_FONT_SIZE = 48
  TITLE_MAX_LENGTH = 40
  INFO_FONT_SIZE = 28 # 著者・ステータス・理由で統一
  REASON_MAX_LENGTH = 80

  # 色設定
  TEXT_COLOR = '#333333' # ダークグレー

  def initialize(reading)
    @reading = reading
    @book = reading.book
  end

  def generate
    # 背景画像を読み込み
    image = MiniMagick::Image.open(Rails.root.join('app/assets/images/ogp/ogp_background.jpg'))

    # テキスト情報を追加
    add_title(image)
    add_author(image) if @book.author.present?
    add_status(image)
    add_reason(image) if @reading.reason.present?

    # 一時ファイルとして保存
    tempfile = Tempfile.new(['ogp', '.jpg'])
    image.write(tempfile.path)
    tempfile
  end

  private

  def add_title(image)
    title = truncate_text(@book.title, TITLE_MAX_LENGTH)

    image.combine_options do |c|
      c.font FONT_PATH
      c.fill TEXT_COLOR
      c.pointsize TITLE_FONT_SIZE
      c.gravity 'NorthWest'
      c.draw "text #{TEXT_LEFT},#{TITLE_TOP} '#{escape_text(title)}'"
    end
  end

  def add_author(image)
    author = "著: #{truncate_text(@book.author, 20)}"

    image.combine_options do |c|
      c.font FONT_PATH
      c.fill TEXT_COLOR
      c.pointsize INFO_FONT_SIZE
      c.gravity 'NorthWest'
      c.draw "text #{TEXT_LEFT},#{AUTHOR_TOP} '#{escape_text(author)}'"
    end
  end

  def add_status(image)
    status_text = "ステータス: #{status_label}"

    image.combine_options do |c|
      c.font FONT_PATH
      c.fill TEXT_COLOR
      c.pointsize INFO_FONT_SIZE
      c.gravity 'NorthWest'
      c.draw "text #{TEXT_LEFT},#{STATUS_TOP} '#{escape_text(status_text)}'"
    end
  end

  def add_reason(image)
    reason = "理由: #{truncate_text(@reading.reason, REASON_MAX_LENGTH)}"

    image.combine_options do |c|
      c.font FONT_PATH
      c.fill TEXT_COLOR
      c.pointsize INFO_FONT_SIZE
      c.gravity 'NorthWest'
      c.draw "text #{TEXT_LEFT},#{REASON_TOP} '#{escape_text(reason)}'"
    end
  end

  def status_label
    case @reading.status
    when 'wish'
      '気になる'
    when 'tsundoku'
      '積読'
    when 'completed'
      '読了'
    else
      '不明'
    end
  end

  def truncate_text(text, max_length)
    return text if text.length <= max_length

    "#{text[0...max_length]}..."
  end

  def escape_text(text)
    # ImageMagickの特殊文字をエスケープ
    text.gsub("'", "\\\\'").gsub('"', '\\"')
  end
end
