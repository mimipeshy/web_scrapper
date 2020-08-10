require_relative '../lib/scrapper.rb'
require 'nokogiri'
require 'httparty'

describe Scrapper do
  let(:url) { 'https://www.buyrentkenya.com/flats-apartments-for-rent?page=1' }
  let(:unparsed_page) { HTTParty.get(url) }
  let(:parsed_page) { Nokogiri::HTML(unparsed_page) }
  let(:property_listing){parsed_page.css('div.result-card-item').text}
  let(:new_results) { Scrapper.new}
  let(:properties) {[]}
  let(:property) do {
                  property_title: property_listing.css('h2.property-title').text.gsub("\n", ""),
                  property_location: property_listing.css('div.property-location').text.gsub("\n", ""),
                  address: property_listing.css('address.property-address').text.gsub("\n", ""),
                  price: property_listing.css('a.item-price').text.gsub("\n", ""),
                  url: "https://www.buyrentkenya.com" + property_listing.css('a')[0].attributes["href"].value  
  }
end
  describe '#new_results' do
    it 'checks if new results is an instance of scrapper' do
      expect(new_results).to be_instance_of Scrapper
    end
  end
    
  describe '#count_properties' do
    it 'counts the total number of properties' do
     expect(new_results.properties.count).to eql(20)
    end
  end
  describe '#user_options' do
    it 'checks if a user inputs an answer between 1 and 4' do
       expect(new_results.user_options(1).to_i).to be_between(1, 4)
    end
    it 'keeps requesting when answer is not between 1 and 5' do
      expect(new_results.user_options(7).to_i).to be_between(1, 4)
    end
  end
  describe '#menu_options' do
    context 'it checks if the menu options correspond to given methods' do
    it 'returns the property details' do
      expect(new_results.property_details).to eql(new_results.menu_options(1))
    end
    it 'returns the property details' do
      expect(new_results.count_properties).to eql(new_results.menu_options(2))
    end
    it 'returns the property details' do
      expect(new_results.highest_price).to eql(new_results.menu_options(3))
    end
    it 'returns the property details' do
      expect(new_results.export_csv).to eql(new_results.menu_options(4))
    end
  end
  end
end