# frozen_string_literal: true

require 'mini_magick'
require 'open-uri'

# 動的OGP画像生成サービス
class OgpImageGenerator
  IMAGE_WIDTH = 1200
  IMAGE_HEIGHT = 630

  # 書籍表紙画像の設定
  BOOK_COVER_LEFT = 80
  BOOK_COVER_HEIGHT = 450
  BOOK_COVER_WIDTH = 300

  # テキスト情報の設定
  TEXT_LEFT = 420
  TITLE_TOP = 200
  AUTHOR_TOP = 300
  STATUS_TOP = 360

  # フォント設定
  FONT_PATH = Rails.root.join('app/assets/fonts/NotoSansJP-VariableFont_wght.ttf').to_s
  TITLE_FONT_SIZE = 48
  AUTHOR_FONT_SIZE = 32
  STATUS_FONT_SIZE = 28

  # 色設定
  TEXT_COLOR = '#333333' # ダークグレー
  BORDER_COLOR = '#CCCCCC' # 枠線用

  def initialize(reading)
    @reading = reading
    @book = reading.book
  end

  def generate
    # 背景画像を読み込み
    image = MiniMagick::Image.open(Rails.root.join('app/assets/images/ogp/ogp_background.jpg'))

    # 書籍表紙画像を追加
    add_book_cover(image) if @book.image_url.present?

    # テキスト情報を追加
    add_title(image)
    add_author(image) if @book.author.present?
    add_status(image)

    # 一時ファイルとして保存
    tempfile = Tempfile.new(['ogp', '.jpg'])
    image.write(tempfile.path)
    tempfile
  end

  private

  def add_book_cover(image)
    # 書籍表紙画像を取得
    cover_image = fetch_cover_image
    return unless cover_image

    # アスペクト比を維持してリサイズ
    cover_image.resize "#{BOOK_COVER_WIDTH}x#{BOOK_COVER_HEIGHT}>"

    # 実際のサイズを取得
    cover_width = cover_image.width
    cover_height = cover_image.height

    # 中央配置のためのオフセット計算
    offset_y = BOOK_COVER_HEIGHT / 2 - cover_height / 2 + (IMAGE_HEIGHT - BOOK_COVER_HEIGHT) / 2

    # 枠線付きで合成
    image.composite(cover_image) do |c|
      c.geometry "+#{BOOK_COVER_LEFT}+#{offset_y}"
      c.compose 'Over'
    end

    # 枠線を追加
    draw_border(image, BOOK_COVER_LEFT, offset_y, cover_width, cover_height)
  rescue StandardError => e
    Rails.logger.error "表紙画像の追加に失敗: #{e.message}"
  end

  def fetch_cover_image
    unless @book.image_url.present?
      Rails.logger.info "OGP: 書籍に画像URLがありません (Reading #{@reading.id})"
      return nil
    end

    Rails.logger.info "OGP: 表紙画像を取得中... URL: #{@book.image_url}"

    URI.parse(@book.image_url).open do |file|
      image = MiniMagick::Image.read(file)
      Rails.logger.info "OGP: 表紙画像の取得に成功 (#{image.width}x#{image.height})"
      image
    end
  rescue StandardError => e
    Rails.logger.error "OGP: 表紙画像の取得に失敗: #{e.class} - #{e.message}"
    Rails.logger.error e.backtrace.first(5).join("\n")
    nil
  end

  def draw_border(image, x, y, width, height)
    image.combine_options do |c|
      c.draw "rectangle #{x - 2},#{y - 2} #{x + width + 2},#{y + height + 2}"
      c.fill 'none'
      c.stroke BORDER_COLOR
      c.strokewidth 2
    end
  end

  def add_title(image)
    title = truncate_text(@book.title, 30)

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
      c.pointsize AUTHOR_FONT_SIZE
      c.gravity 'NorthWest'
      c.draw "text #{TEXT_LEFT},#{AUTHOR_TOP} '#{escape_text(author)}'"
    end
  end

  def add_status(image)
    status_text = "ステータス: #{status_label}"

    image.combine_options do |c|
      c.font FONT_PATH
      c.fill TEXT_COLOR
      c.pointsize STATUS_FONT_SIZE
      c.gravity 'NorthWest'
      c.draw "text #{TEXT_LEFT},#{STATUS_TOP} '#{escape_text(status_text)}'"
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
