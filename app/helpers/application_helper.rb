# frozen_string_literal: true

module ApplicationHelper
  def default_meta_tags
    {
      site: 'Tsundoku',
      title: '積読本の記録管理サービス',
      reverse: 'true',
      charset: 'utf-8',
      description: 'Tsundokuでは、積読をより楽しくするために、積読本記録管理を行うことができます',
      keywords: '積読,読書,本,記録',
      canonical: request.original_url,
      separator: '|',
      og: {
        site_name: :site,
        title: :title,
        description: :description,
        type: 'website',
        url: request.original_url,
        image: image_url('ogp.jpg'),
        locale: 'ja_JP'
      },
      twitter: {
        card: 'summary_large_image',
        site: '@obvyamdres',
        image: image_url('ogp.jpg')
      }
    }
  end
end
