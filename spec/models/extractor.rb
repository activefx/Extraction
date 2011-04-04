require File.expand_path('../../../lib/extraction', __FILE__)

class Extractor
  include Extraction::Base

  fields :field1, :field2
  field :field3
  attributes :field5, :field6

#      field :field1
#      field :field2

  #fields :field3, :field4


#      parser :nokogiri #Nokogiri::HTML

#      field :metadata

#      parse :site, "RateMD"
#      parse :identifier, :xpath => '//h3/a[@class="l"]'
#      parse :url, :css => 'a.title'
#      parse :name, lambda {|n| n.at_css('a.name').gsub(/\n/, " ").content }
#      parse :city, find_city

#      extracts_many :reviews
#      extracts_one :owner

#      def find_city
#        @parsed_data.at_css('a.city').gsub(/\n/, " ").content
#      end

end

