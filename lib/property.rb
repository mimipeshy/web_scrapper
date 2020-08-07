require_relative '..lib/scrapper.rb'

class Properties

  attr_reader :properties
  def initialize
    @properties = []
    @property_listings = @parsed_page.css('div.result-card-item')
    @per_page = @property_listings.count
    @total = @parsed_page.css('a.filter-item').text.split(' ')[3].gsub(/[()]/, '').to_i
   
    @page = 1
  end

  def last_page
    @last_page = 10
  end

  def count_properties
    count = @total
    puts 'Total properties for rent: '
    puts count
  end

  def property_details
    @property_listings.each do |i|
      property = {
        property_title: i.css('h2.property-title').text,
        property_location: i.css('div.property-location').text,
        address: i.css('address.property-address').text,
        price: i.css('a.item-price').text
      }
      @properties << property
      puts "Property title #{property[:property_title]}"
      puts "Location #{property[:property_location]}"
      puts "More info  #{property[:address]}"
      puts "Price #{property[:price]}"
      puts ''
    end
  end

  def menu_options(answer)
    case answer
      when 1
        property_details
      when 2
        count_properties
      when 3
        one_property
      when 4
        export_csv
      end
  
    end
  
    def user_options(move)
      unless move.to_i.between?(1, 4)
        return false
        move = gets.chomp
      end
      move
    end
  
 
end