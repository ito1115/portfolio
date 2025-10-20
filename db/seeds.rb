# デフォルト購入媒体を作成
# nameは識別子として使用し、表示名はi18nで管理
default_media = [
  { name: "paperbook", category: "physical" },
  { name: "kindle", category: "digital" },
  { name: "rakuten_kobo", category: "digital" },
  { name: "doly", category: "digital" },
  { name: "other", category: "other" }
]

default_media.each do |medium|
  PurchaseMedium.find_or_create_by!(name: medium[:name]) do |pm|
    pm.category = medium[:category]
  end
end

puts "Created #{PurchaseMedium.count} default purchase media"
