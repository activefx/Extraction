#require File.expand_path('../spec_helper', __FILE__)
#require File.expand_path('../active_model_shared', __FILE__)
#require 'nokogiri'
#require 'hpricot'

##require File.expand_path('../models/extractor', __FILE__)

#describe Extraction do

#  before(:all) do
#    class Extractor
#      include Extraction::Base

#      fields :field1, :field2
#      field :field3
#      attributes :field5, :field6

#    end
#    class SomeParser
#      def self.parse(data)
#        data
#      end
#    end
#  end

#  before(:each) do
#    @extractor = Extractor.new
#  end

#  context "ActiveModel functionality" do
#    subject { @extractor }
#    it_should_behave_like "ActiveModel"
#  end

#  it "should include Extraction::Base" do
#    debugger
#    @extractor.class.include?(Extraction::Base).should be_true
#  end

#  it "should output attributes for defined fields" do
#    @extractor.attributes.has_key?("field1").should be_true
#  end

#  it "should not initialize undefined fields" do
#    @extractor = Extractor.new(:something => 1234)
#    @extractor.attributes.has_key?("something").should be_false
#  end

#  it "should not be able to set attributes if they have not been defined" do
#    lambda{@model.somthing = 1234}.should raise_error
#  end

#  it "should respond to the parse class method" do
#    @extractor.class.respond_to?(:parser).should be_true
#  end

#  it "should respond to the parser method class method" do
#    @extractor.class.respond_to?(:parse).should be_true
#  end

#  it "should define the default parser as the extracting class" do
#    @extractor._parser.should == @extractor.class
#  end

#  it "should set the default parser method" do
#    @extractor._parser_method.should == :parse
#  end

#  it "should not respond to an attribute that has not been defined" do
#    @extractor.respond_to?(:field9999).should be_false
#  end

#  it "should not keep the raw data" do
#    @extractor = Extractor.new("<html></html>")
#    @extractor._unparsed_data.should be_nil
#  end

#  it "should not keep the parsed data" do
#    @extractor = Extractor.new("<html></html>")
#    @extractor._parsed_data.should be_nil
#  end

#  it "should keep the raw data if the option is enabled" do
#    Extractor.class_eval do
#      parser :keep_unparsed_data => true
#    end
#    @extractor = Extractor.new("<html></html>")
#    @extractor._unparsed_data.should == "<html></html>"
#  end

#  it "should keep the raw data if the option is enabled" do
#    Extractor.class_eval do
#      parser Nokogiri::HTML, :keep_parsed_data => true
#    end
#    @extractor = Extractor.new("<html></html>")
#    @extractor._parsed_data.should be_a Nokogiri::HTML::Document
#  end

#  it "should accept a symbol for common parsers (nokogiri)" do
#    Extractor.class_eval do
#      parser :nokogiri
#    end
#    @extractor = Extractor.new
#    @extractor._parser.should == Nokogiri::HTML
#    @extractor._parser_method.should == :parse
#  end

#  it "should raise an error for a symbol's library when it wasn't required or defined" do
#    lambda{Extractor.class_eval{parser :defined_library}}.should raise_error(Extraction::ParserError)
#  end

#  it "should allow the parser method to be set (or overwritten)" do
#    Extractor.class_eval do
#      parser :hpricot, :parser_method => :XML
#    end
#    @extractor = Extractor.new
#    @extractor._parser_method.should == :XML
#  end

#  it "should accept the data to parse using the _raw attribute" do
#    Extractor.class_eval do
#      parser :keep_unparsed_data => true
#    end
#    @extractor = Extractor.new(:_raw => "<html></html>")
#    @extractor._unparsed_data.should == "<html></html>"
#  end

#  it "should allow custom parsers to be defined" do
#    Extractor.class_eval do
#      parser SomeParser, :parser_method => :parse
#    end
#    @extractor = Extractor.new
#    @extractor._parser.should == SomeParser
#  end

#  context "#fields" do

#    it "should respond to defined fields" do
#      @extractor.respond_to?(:field1).should be_true
#      @extractor.respond_to?(:field2).should be_true
#    end

#    it "should allow fields to be set" do
#      @extractor.field2 = 'value'
#      @extractor.field2.should == 'value'
#    end

#    it "should allow fields to be cleared" do
#      @extractor.field2 = "value"
#      @extractor.clear_field2
#      @extractor.field2.should be_nil
#    end

#  end

#  context "#attributes" do

#    it "should respond to defined fields" do
#      @extractor.respond_to?(:field5).should be_true
#      @extractor.respond_to?(:field6).should be_true
#    end

#    it "should allow fields to be set" do
#      @extractor.field6 = 'value'
#      @extractor.field6.should == 'value'
#    end

#    it "should allow fields to be cleared" do
#      @extractor.field6 = "value"
#      @extractor.clear_field6
#      @extractor.field6.should be_nil
#    end

#  end

#  context "#field" do

#    it "should respond to defined fields" do
#      @extractor.respond_to?(:field3).should be_true
#    end

#    it "should allow fields to be set" do
#      @extractor.field3 = 'value'
#      @extractor.field3.should == 'value'
#    end

#    it "should allow fields to be cleared" do
#      @extractor.field3 = "value"
#      @extractor.clear_field3
#      @extractor.field3.should be_nil
#    end

#  end




#end

