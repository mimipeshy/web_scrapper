require_relative '../lib/scrapper.rb'
require 'nokogiri'
require 'httparty'
require 'csv'

describe Scrapper do
  let(:url) { 'https://www.buyrentkenya.com/flats-apartments-for-rent?page=1' }
  let(:unparsed_page) { HTTParty.get(url) }
  let(:parsed_page) { Nokogiri::HTML(unparsed_page) }
  let(:property_listings) { parsed_page.css('div.result-card-item') }
  let(:first_property) {property_listings.first}
  let(:total){ parsed_page.css('a.filter-item').text.split(' ')[3].gsub(/[()]/,'')}
  let(:new_results) { Scrapper.new }
  let(:property) do {
    property_title: first_property.css('h2.property-title').text.gsub("\n", ""),
    property_location: first_property.css('div.property-location').text.gsub("\n", ""),
    address: first_property.css('address.property-address').text.gsub("\n", ""),
    price: first_property.css('a.item-price').text.gsub("\n", ""),
    url: "https://www.buyrentkenya.com" + first_property.css('a')[0].attributes["href"].value  
  }
    end
  describe '#new_results' do
    it 'checks if new results is an instance of scrapper' do
      expect(new_results).to be_instance_of Scrapper
    end
  end

  describe '#count_properties' do
    it 'counts the total number of properties' do
      expect(new_results.count_properties).to eql(total.to_i)
    end
  end

  describe '#user_options' do
    it 'checks if a user inputs an answer between 1 and 4' do
      expect(new_results.user_options(1).to_i).to be_between(1, 4)
    end
  end
  describe '#menu_options' do
    context 'it checks if the menu options correspond to given methods' do
      it 'returns the property details' do
        expect(new_results.send(:property_details)).to eql(property)
      end
      it 'returns the highest property value' do
        expect(new_results.send(:highest_price)).to eql(property[:price])
      end
      it 'returns the property details' do
        expect(new_results.export_csv).to eql(new_results.menu_options(4))
      end
    end
  end
end
