require 'nokogiri'
require 'httparty'
require 'byebug'
require 'csv'

class Scrapper
  attr_reader :properties
  def initialize
    @url = 'https://www.buyrentkenya.com/flats-apartments-for-rent'
    @unparsed_page = HTTParty.get(@url)
    @parsed_page = Nokogiri::HTML(@unparsed_page)
    @properties = []
    @property_prices = []
    @property_listings = @parsed_page.css('div.result-card-item')
    @per_page = @property_listings.count
    @total = @parsed_page.css('a.filter-item').text.split(' ')[3].gsub(/[()]/, '').to_i
    @page = 1
    @last_page = 2
  end

  def count_properties
    @total
  end

  def highest_price
    save_property
    @property_prices << properties[0][:price]
    highest = @property_prices.max
    highest
  end

  def property_details
    save_property
    properties[0]
  end

  def pagination
    pagination_url = "https://www.buyrentkenya.com/flats-apartments-for-rent?page=#{@page}"
    puts pagination_url
    puts "Page : #{@page}"
    puts ''
    save_property
    puts @page += 1
  end

  def export_csv
    pagination while @page <= @last_page
    CSV.open('reserved.csv', 'w') { |csv| csv << @properties }
    puts 'exporting .....'
  end

  def menu_options(answer)
    case answer
    when 1
      p property_details
    when 2
      p count_properties
    when 3
      p highest_price
    when 4
      export_csv
    end
  end

  def user_options(move)
    until move.to_i.between?(1, 4)
      puts 'Invalid choice! Choose between 1 and 4'
      move = gets.chomp
    end
    move.to_i
  end

  private

  def save_property
    @property_listings.each do |i|
      property = {
        property_title: i.css('h2.property-title').text.gsub("\n", ''),
        property_location: i.css('div.property-location').text.gsub("\n", ''),
        address: i.css('address.property-address').text.gsub("\n", ''),
        price: i.css('a.item-price').text.gsub("\n", ''),
        url: 'https://www.buyrentkenya.com' + i.css('a')[0].attributes['href'].value
      }
      @properties << property
    end
  end
end
