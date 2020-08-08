require_relative '../lib/scrapper.rb'
require 'nokogiri'
require 'httparty'

describe Scrapper do
  let(:url) { 'https://www.buyrentkenya.com/flats-apartments-for-rent' }
  let(:unprosessed_page) { HTTParty.get(url) }
  let(:prosessed_page) { Nokogiri::HTML(unprosessed_page) }
  let(:prosessed_articles) { prosessed_page.css('div.result-card-item') }
  let(:web_data) { ArticleProcess.new(url) }
  let(:check_arr) do
    { title: first_article.css('a.product-title').text,
      price: first_article.css('div.price-block__highlight').text.split.join(' ').gsub!(/\s/, ','),
      availability: (if first_article.css('div.product-delivery-highlight').text.empty?
                       'niet op voorraad'
                     else
                       first_article.css('div.product-delivery-highlight').text
                     end),
      link: 'bol.com' + first_article.css('a')[0].attributes['href'].value }
end