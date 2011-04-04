require File.expand_path('../../../lib/extraction', __FILE__)

class HtmlExtractor
  include Extraction::Base

  debug_mode!

  parser :nokogiri, :parser_method => :parse,
                    :keep_parsed_data => true,
                    :keep_unparsed_data => true

  field :url
  field :site, "Google"
  field :title

#  extracts_many :links
#  extracts_many :alternatives
#  extracts_one :query
#  extracts_one :feedback_link

#  output_nested_attributes_for :links
#  output_nested_attributes_for :feedback_link

  def extract_title
    at_css('title').text
  end

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

