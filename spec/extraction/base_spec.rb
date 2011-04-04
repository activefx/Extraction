require 'spec_helper'
require 'active_model_shared'
require 'nokogiri'
require 'hpricot'
require 'lumberjack'

#require File.expand_path('../models/extractor', __FILE__)

describe Extraction do

  before(:all) do
    class Extractor
      include Extraction::Base

      fields :field1, :field2
      field :field3
      attributes :field4, :field5

    end
    class SomeParser
      def self.some_parser_method(data)
        data
      end
    end
  end

  before(:each) do
    @extractor = Extractor.new
  end

  context "ActiveModel functionality" do
    subject { @extractor }
    it_should_behave_like "ActiveModel"
  end

  it "should include Extraction::Base" do
    @extractor.class.include?(Extraction::Base).should be_true
  end

  context "Class Method" do

    context "#fields" do

      it "should respond to defined fields" do
        @extractor.respond_to?(:field1).should be_true
        @extractor.respond_to?(:field2).should be_true
      end

      it "should allow fields to be set" do
        @extractor.field2 = 'value'
        @extractor.field2.should == 'value'
      end

      it "should allow fields to be cleared" do
        @extractor.field2 = "value"
        @extractor.clear_field2
        @extractor.field2.should be_nil
      end

    end

    context "#attributes" do

      it "should respond to defined fields" do
        @extractor.respond_to?(:field4).should be_true
        @extractor.respond_to?(:field5).should be_true
      end

      it "should allow fields to be set" do
        @extractor.field5 = 'value'
        @extractor.field5.should == 'value'
      end

      it "should allow fields to be cleared" do
        @extractor.field5 = "value"
        @extractor.clear_field5
        @extractor.field5.should be_nil
      end

    end

    context "#field" do

      it "should respond to defined fields" do
        @extractor.respond_to?(:field3).should be_true
      end

      it "should allow fields to be set" do
        @extractor.field3 = 'value'
        @extractor.field3.should == 'value'
      end

      it "should allow fields to be cleared" do
        @extractor.field3 = "value"
        @extractor.clear_field3
        @extractor.field3.should be_nil
      end

    end

    context "#parser" do

      it "should respond to the parse class method" do
        @extractor.class.respond_to?(:parser).should be_true
      end

      it "should define the default parser as the extracting class" do
        @extractor._parser.should == @extractor.class
      end

      it "should not respond to an attribute that has not been defined" do
        @extractor.respond_to?(:field9999).should be_false
      end

      it "should accept a symbol for common parsers (nokogiri)" do
        class CommonParserSymbol < Extractor
          parser :nokogiri
        end
        @extractor = CommonParserSymbol.new
        @extractor._parser.should == Nokogiri::HTML
        @extractor._parser_method.should == :parse
      end

      it "should raise an error for a symbol's library when it wasn't required or defined" do
        class ParserLibraryError < Extractor; end
        lambda{ ParserLibraryError.class_eval{parser :defined_library} }.
          should raise_error(Extraction::ParserError)
      end

      it "should allow custom parsers to be defined" do
        class CustomParser < Extractor
          parser SomeParser, :parser_method => :some_parser_method
        end
        @extractor = CustomParser.new
        @extractor._parser.should == SomeParser
      end

    end

    context "#parser_method" do

      it "should respond to the parser method class method" do
        @extractor.class.respond_to?(:parse).should be_true
      end

      it "should set the default parser method" do
        @extractor._parser_method.should == :parse
      end

      it "should allow the parser method to be set or overwritten (with parser options)" do
        class ParserMethodOverride < Extractor
          parser :hpricot, :parser_method => :XML
        end
        @extractor = ParserMethodOverride.new
        @extractor._parser_method.should == :XML
      end

      it "should allow the parser method to be set or overwritten (with a class method)" do
        class ParserMethodOverrideTwo < Extractor
          parser :hpricot
          parser_method :XML
        end
        @extractor = ParserMethodOverrideTwo.new
        @extractor._parser_method.should == :XML
      end

    end

    context "#keep_parsed_data" do

      it "should keep the parsed data if the option is enabled (with parser options)" do
        class KeepParsedData < Extractor
          parser Nokogiri::HTML, :keep_parsed_data => true
        end
        @extractor = KeepParsedData.new("<html></html>")
        @extractor.parsed_data.should be_a Nokogiri::HTML::Document
      end

      it "should keep the parsed data if the option is enabled (with a class method)" do
        class KeepParsedDataTwo < Extractor
          parser Nokogiri::HTML
          keep_parsed_data true
        end
        @extractor = KeepParsedData.new("<html></html>")
        @extractor.parsed_data.should be_a Nokogiri::HTML::Document
      end

    end

    context "#keep_unparsed_data" do

      it "should keep the raw data if the option is enabled (with parser options)" do
        class KeepRawData < Extractor
          parser :keep_unparsed_data => true
        end
        @extractor = KeepRawData.new("<html></html>")
        @extractor.unparsed_data.should == "<html></html>"
      end

      it "should keep the raw data if the option is enabled (with a class method)" do
        class KeepRawDataTwo < Extractor
          keep_unparsed_data true
        end
        @extractor = KeepRawDataTwo.new("<html></html>")
        @extractor.unparsed_data.should == "<html></html>"
      end

    end

    context "#new" do

      it "should not keep the raw data" do
        @extractor = Extractor.new("<html></html>")
        @extractor.unparsed_data.should be_nil
      end

      it "should not keep the parsed data" do
        @extractor = Extractor.new("<html></html>")
        @extractor.parsed_data.should be_nil
      end

      it "should accept the data to parse using the _raw attribute" do
        class AcceptRawAttribute < Extractor
          parser :keep_unparsed_data => true
        end
        @extractor = AcceptRawAttribute.new(:_raw => "<html></html>")
        @extractor.unparsed_data.should == "<html></html>"
      end

    end

  end

  context "#attributes" do

    it "should output attributes for defined fields" do
      @extractor.attributes.has_key?("field1").should be_true
    end

    it "should set the default value for attributes to nil" do
      @extractor.field1.should be_nil
      @extractor.attributes[:field1].should be_nil
    end

    it "should not initialize undefined fields" do
      @extractor = Extractor.new(:something => 1234)
      @extractor.attributes.has_key?("something").should be_false
    end

    it "should not be able to set attributes if they have not been defined" do
      lambda{@model.somthing = 1234}.should raise_error
    end

  end

  context "#uninitialized_attributes" do

    it "should include all defined attributes when none have been initialized" do
      @extractor.uninitialized_attributes.count.should == 5
    end

    it "should not include attributes that have been initialized" do
      @extractor = Extractor.new(:field1 => 1234)
      @extractor.uninitialized_attributes.count.should == 4
      @extractor.uninitialized_attributes.include?(:field1).should be_false
    end

  end

  context "#parsed_data" do

    it "should have a method to get the parsed data" do
      @extractor.parsed_data.should be_nil
    end

  end

  context "#unparsed_data" do

    it "should have a method to get the unparsed data" do
      @extractor.unparsed_data.should be_nil
    end

  end

  context "#debug_mode?" do

    it "should report if the extractor was run in debug mode" do
      @extractor.debug_mode?.should be_false
    end

  end

  context "#logger" do

    it "should have a method to access the logger" do
      lambda{@extractor.logger.some_method}.should_not raise_error
    end

  end

  context "#log_entire_exception?" do

    it "should be set to the log the entire exception message from any error by default" do
      @extractor.log_entire_exception?.should be_true
    end

  end

  context "#error_message" do

    it "should produce an error message summary when called" do
      @extractor.error_message.should =~ /EXTRACTION FAILURE .+ Class:Extractor/
    end

    it "should include the attribute with the message when passed as an argument" do
      @extractor.error_message(:field1).should =~ /EXTRACTION FAILURE .+ Class:Extractor Cause:field1/
    end

  end

  context "#error_alert" do

    it "should be called by the exception_handler if the error_alert method if defined" do
      class ErrorAlertTest < Extractor
        attr_accessor :error_alert_attribute, :error_alert_exception
        def error_alert(attribute, exception)
          @error_alert_attribute = "some attribute"
          @error_alert_exception = "some exception"
        end
      end
      @extractor = ErrorAlertTest.new
      @extractor.exception_handler("some exception", "some attribute")
      @extractor.error_alert_attribute.should == "some attribute"
      @extractor.error_alert_exception.should == "some exception"
    end

  end


  context "#exception_handler" do

    let(:output){ StringIO.new }
    let(:lumberjack){ Lumberjack::Logger.new(output, :buffer_size => 0, :level => Lumberjack::Severity::INFO) }

    before(:all) do
      class LoggerTest < Extractor
        def extract_field1
          raise StandardError, "Your extractor broke"
        end
      end
      LoggerTest.logger(lumberjack)
    end

    before(:each) do
      @extractor = LoggerTest.new("some data")
    end

    it "should send the logger the error message" do
      output.string.lines.first.should =~ /Class:LoggerTest Cause:field1/
    end

    it "should send the logger the exception" do
      output.string.lines.drop(1).first.should =~ /StandardError: Your extractor broke/
    end

  end

  context "#method_missing" do

    it "should automatically call method on the parsed data if available" do
      class MethodMissingTest < Extractor
        parser :nokogiri
        debug_mode
        def extract_field1
          at_css('title').text
        end
      end
      @extractor = MethodMissingTest.new("<html><title>Hello</title></html>")
      @extractor.field1.should == "Hello"
    end

    it "should not parse an attribute when calling an undefined method on the parser (in debug mode)" do
      class MethodMissingTestTwo < Extractor
        parser :nokogiri
        def extract_field1
          not_a_nokogiri_method('title')
        end
      end
      @extractor = MethodMissingTestTwo.new("<html><title>Hello</title></html>")
      @extractor.field1.should be_nil
    end

    it "should raise an error when calling an undefined method on the parser (in debug mode)" do
      class MethodMissingTestThree < Extractor
        parser :nokogiri
        debug_mode
        def extract_field1
          not_a_nokogiri_method('title')
        end
      end
      lambda{MethodMissingTestThree.new("<html><title>Hello</title></html>")}.should raise_error
    end

  end


end

