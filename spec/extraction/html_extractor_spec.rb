require 'spec_helper'
require File.expand_path('../../models/html_extractor', __FILE__)

describe "HTML Extraction Example" do

  use_vcr_cassette "google_ruby_search"

  def search
    Net::HTTP.get_response(URI.parse(
      "http://www.google.com/search?q=ruby"
    ))
  end

  before(:each) do
    @search = HtmlExtractor.new(search.body)
  end

  it "should extract the title" do
    @search.title.should == "ruby - Google Search"
  end

end

