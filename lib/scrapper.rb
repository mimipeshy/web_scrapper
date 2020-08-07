# frozen_string_literal: true

require 'nokogiri'
require 'httparty'
require 'byebug'
require 'csv'

class Scrapper

  attr_reader :properties 
  # attr_accessor :property_prices
  def initialize
    @url = 'https://www.buyrentkenya.com/flats-apartments-for-rent'
    @unparsed_page = HTTParty.get(@url)
    @parsed_page = Nokogiri::HTML(@unparsed_page)
    @properties = []
    @property_listings = @parsed_page.css('div.result-card-item')
    @per_page = @property_listings.count
    @total = @parsed_page.css('a.filter-item').text.split(' ')[3].gsub(/[()]/, '').to_i
    @last_page = (@total.to_f / @per_page.to_f).round
    @page = 1
  end

  def last_page
    @last_page = 6
  end
  def count_properties
    count = @total
    puts 'Total properties for rent: '
    puts count
  end

  def set_up_details
    @property_listings.each do |i|
      property = {
        property_title: i.css('h2.property-title').text.gsub("\n", ""),
        property_location: i.css('div.property-location').text.gsub("\n", ""),
        address: i.css('address.property-address').text.gsub("\n", ""),
        price: i.css('a.item-price').text.gsub("\n", "")       
      }
      @properties << property
      @property_prices << property[:price].split(" ")[1].gsub(",", "").to_i
    end
  end

  def property_details
    @property_listings.each do |property_listing|
      property = {
        property_title: property_listing.css('h2.property-title').text.gsub("\n", ""),
        property_location: property_listing.css('div.property-location').text.gsub("\n", ""),
        address: property_listing.css('address.property-address').text.gsub("\n", ""),
        price: property_listing.css('a.item-price').text.gsub("\n", "")       
      }
      @properties << property
      puts "Property title #{property[:property_title]}"
      puts "Location #{property[:property_location]}"
      puts "More info  #{property[:address]}"
      puts "Price #{property[:price]}"
      puts ''
    end
    @properties
  end
  

  def pagination
    pagination_url = "https://www.buyrentkenya.com/flats-apartments-for-rent?page=#{@page}"
    puts pagination_url
    puts "Page : #{@page}"
    puts ''
    pagination_unparsed_page = HTTParty.get(pagination_url)
    pagination_parsed_page = Nokogiri::HTML(pagination_unparsed_page)
    pagination_property_listings = pagination_parsed_page.css('div.result-card-item')
    property_details
    @page += 1
  end

  def export_csv
    pagination while @page <= last_page
    CSV.open('reserved.csv', 'w') { |csv| csv << @properties }
    puts 'exporting .....'
  end

  def menu_options(answer)
    case answer
    when 1
      property_details
    when 2
      count_properties
    when 3
      export_csv
    end
  end

  def user_options(move)
    until move.to_i.between?(1, 4)
      puts 'Invalid choice! Choose between 1 and 4'
      move = gets.chomp
    end
    menu_options(move)
  end
end

