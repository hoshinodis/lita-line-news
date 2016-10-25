require "open-uri"
require "nokogiri"

module Lita
  module Handlers
    class LineNews < Handler

      route(/ln+\p{blank}+(?<url>.*)/, :exec)

      def exec(response)
        url = response.match_data['url']

        html = Nokogiri::HTML(open(url))
        titles = html.css('.MdCMN03Article').css('.mdCMN03AtclTtl').map{|a| a.content} #タイトル
=begin
        html.css('.MdCMN03Article').first.children.children.children.children.first.content
        html.css('.MdCMN03Article').map{|a| a.children.children.children.children.children[1].content} #参照元1？
        html.css('.MdCMN03Article').map{|a| a.children.children.children.children.children.children}.map{|a| a.map(&:content)}.map{|a| a[1]}
        html.css('.MdCMN03Article').map{|a| a.children.children.children.children.children.children}.map{|a| a.map(&:content)}.map{|a| a[3]}
        html.css('.MdCMN03Article').map{|a| a.children.children.children.children.children.children}.map{|a| a.map(&:content)}.map{|a| a[5]}
        html.css('.MdCMN03Article')[1].children[3].children[1].children[7].children.first.children.children[1].content
        html.css('.MdCMN03Article')[1].children[3].children[1].children[11].children.first.children.children[1].content

        html.css('.MdCMN03Article').map{|a| a.children.children.children.children.children.children}[3][3].content

        html.css('.MdCMN03Article').map{|a| a.children.children.children.children.children.children}.map{|a| a.map(&:content)}.map{|a| a}
=end
        medium1 = html.css('.MdCMN03Article').map{|a| a.children.children.children.children.children.children}.map{|a| a.map(&:content)}.map{|a| a[1]} #掲載元1
        medium2 = html.css('.MdCMN03Article').map{|a| a.children.children.children.children.children.children}.map{|a| a.map(&:content)}.map{|a| a[3]} #掲載元2
        medium3 = html.css('.MdCMN03Article').map{|a| a.children.children.children.children.children.children}.map{|a| a.map(&:content)}.map{|a| a[5]} #掲載元3

        reply_title = ''
        titles.length.times do |n|
          reply_title = "#{reply_title}#{titles[n]}\n"
        end

        reply_medium = ''
        titles.length.times do |n|
          reply_medium = "#{reply_medium}#{medium1[n]}\t#{medium2[n]}\t#{medium3[n]}\n"
        end

        response.reply("タイトル全文\n```\n#{reply_title}\n```")
        response.reply("参照元メディア\n```\n#{reply_medium}\n```")
      rescue OpenURI::HTTPError => e
        response.reply("情報がなかったよ。URLが正しいか確認してね。")
        response.reply("今回使用したURL:#{url}")
      end

      Lita.register_handler(self)
    end
  end
end
