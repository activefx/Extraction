module Extraction
  class ParserError < StandardError; end

  module Base
    extend ActiveSupport::Concern

    included do
      extend  ActiveModel::Callbacks
      extend  ActiveModel::Naming
      include ActiveModel::AttributeMethods
      include ActiveModel::Conversion
      include ActiveModel::Serializers::JSON
      include ActiveModel::Serializers::Xml
      include ActiveModel::Validations

      #include Extraction::Middleware
      #include Extraction::Setup
      #include Extraction::Attributes

      class_attribute :_attributes
      class_attribute :_parser
      class_attribute :_parser_method
      class_attribute :_keep_parsed_data
      class_attribute :_keep_unparsed_data
      class_attribute :_debug_mode
      class_attribute :_logger
      class_attribute :_log_entire_exception
      class_attribute :_middleware_response
      class_attribute :_middleware_response_format

      self._attributes = []
      self._parser = self
      self._parser_method = :parse
      self._keep_parsed_data = false
      self._keep_unparsed_data = false
      self._debug_mode = false
      self._logger = fake_logger
      self._log_entire_exception = true
      self._middleware_response = true
      self._middleware_response_format = :attributes

      attribute_method_suffix '?'
      attribute_method_prefix 'clear_'
      attribute_method_affix  :prefix => 'extract_',
                              :suffix => '_wrapper'

      define_model_callbacks :initialization
      define_model_callbacks :parsing
      define_model_callbacks :extraction

      attr_reader :errors, :parsed_data, :unparsed_data

    end

    def initialize(*args)
      _run_initialization_callbacks do
        attributes = args.extract_options!
        initialize_model_errors
        initialize_unparsed_data([attributes, args])
        initialize_defined_attributes(attributes)
        process_data
        discard_data
      end
    end

    def attributes
      self._attributes.inject({}) do |hash, attr|
        hash[attr.to_s] = send(attr)
        hash
      end
    end

    def uninitialized_attributes
      _attributes - instance_variable_names.collect{|i| i.sub(/^@/, '').to_sym}
    end

    def to_model
      self
    end

    def persisted?
      false
    end

    def debug_mode?
      !!self._debug_mode
    end

    def logger
      _logger
    end

    def log_entire_exception?
      !!self._log_entire_exception
    end

    def exception_handler(exception, cause = nil)
      error_alert( exception, cause ) if respond_to?(:error_alert)
      logger.error( error_message(cause) )
      logger.error( exception ) if log_entire_exception?
    end

    def error_message(cause = nil)
      message = "EXTRACTION FAILURE #{Time.now} Class:#{self.class}"
      unless cause.nil?
        message << " Cause:#{cause}"
      end
      message
    end

    def method_missing(method, *args)
      if parsed_data.respond_to?(method)
        parsed_data.send(method, *args)
      else
        super
      end
    end

    protected

    def clear_attribute(attribute)
      send("#{attribute}=", nil)
    end

    def attribute?(attribute)
      send(attribute).present?
    end

    def extract_attribute_wrapper(attribute)
      return if instance_variable_defined?("@#{attribute}")
      return unless respond_to?("extract_#{attribute}")
      instance_variable_set( "@#{attribute}",
        extraction_logic_for(attribute) )
    end

    def extraction_logic_for(attribute)
      return send("extract_#{attribute}") if debug_mode?
      begin
        send("extract_#{attribute}")
      rescue => exception
        exception_handler(exception, attribute)
        nil
      end
    end

    def initialize_model_errors
      @errors = ActiveModel::Errors.new(self)
    end

    # Assumes first element in the array is the attributes, and
    # the last element is the data to parse, in this case allowing
    # the data to parse to be overwritten or initialized by initializing
    # the extractor with a :_raw attribute
    def initialize_unparsed_data(data_array)
      if data_array.first[:_raw]
        @unparsed_data = data_array.first[:_raw]
      else
        @unparsed_data = data_array.last.first
      end
    end

    def initialize_defined_attributes(attributes = nil)
      return if attributes.blank?
      attributes.each do |attr, value|
        send("#{attr}=", value) if respond_to?("#{attr}=")
      end
    end

    def process_data
      return unless unparsed_data
      parse_data
      preprocess_data if respond_to?(:preprocess_data)
      _run_extraction_callbacks do
        data_extraction
      end
    end

    def parse_data
      _run_parsing_callbacks do
        @parsed_data = execute_parsing
      end
    end

    def execute_parsing
      return _parser.send("#{_parser_method}", unparsed_data) if debug_mode?
      begin
        _parser.send("#{_parser_method}", unparsed_data)
      rescue => exception
        exception_handler(exception, "#{_parser}.#{_parser_method}")
        nil
      end
    end

    def data_extraction
      return if uninitialized_attributes.blank?
      uninitialized_attributes.each do |attr|
        send("extract_#{attr}_wrapper")
      end
    end

    def discard_data
      @unparsed_data = nil unless _keep_unparsed_data
      @parsed_data   = nil unless _keep_parsed_data
    end

    module ClassMethods

      def parse(data)
        data
      end

      def fields(*names)
        attr_accessor *names
        define_attribute_methods names
        self._attributes += names
      end
      alias :attributes :fields

      #TODO: Define dynamic method from field options
      # field :title, :at_css => '.title'
      #               :after => :text
      #               :before => :something
      # send(options[:before]) if options[:before]
      # send(key, value)
      # send(options[:after]) if options[:after]
      def field(name, options = {})
        attr_accessor name
        define_attribute_methods [name]
        self._attributes += [name]
      end

      def extracts_many(name, options = {})

      end

      def extracts_one(name, options = {})

      end

      def parser(*args)
        options = args.extract_options!
        set_parser(args.first) if args.first
        keep_parsed_data(options[:keep_parsed_data])
        keep_unparsed_data(options[:keep_unparsed_data])
        parser_method(options[:parser_method])
        ensure_parser_compatibility
      end

      def keep_parsed_data(value = nil)
        self._keep_parsed_data = !!value if value
      end

      def keep_unparsed_data(value = nil)
        self._keep_unparsed_data = !!value if value
      end

      def parser_method(method = nil)
        self._parser_method = method if method
      end

      def debug_mode(value = true)
        self._debug_mode = !!value
      end
      alias :debug_mode! :debug_mode

      def logger(*args)
        options = args.extract_options!
        set_logger(args.first) if args.first
        log_entire_exception(options[:log_entire_exception])
      end

      def log_entire_exception(value = nil)
        self._log_entire_exception = !!value if value
      end

      def middleware_response(value = true)
        self._middleware_response = !!value
      end

      def middleware_response_format(method = :attributes)
        self._middleware_response = method
      end

      def middleware
        middleware_klass = Class.new
        middleware_klass.class_eval <<-END

          def klass
            #{self}
          end

          #def request(head, body)
          #  [head, body]
          #end

          def response(resp)
            data = #{self}.new(resp.response)
#            if #{self._middleware_response} == true
#              data = data.send(#{self._middleware_response_format})
#            end
            resp.response = data
          end

        END
        middleware_klass
      end

      protected

      def set_parser(parser_name)
        case parser_name
        when :nokogiri
          require 'nokogiri'
          # TODO
          # self.send(:include, Extraction::NokogiriExtensions)
          self._parser = Nokogiri::HTML
          self._parser_method = :parse
        when :hpricot
          require 'hpricot'
          self._parser = Hpricot
          self._parser_method = :parse
        else
          self._parser = parser_name
        end
      end

      def ensure_parser_compatibility
        unless _parser.respond_to? _parser_method
          raise ParserError,
            "#{_parser} does not respond to #{_parser_method}"
        end
      end

      def set_logger(logger_instance)
        # case logger_instance
        # when :lumberjack
        # self.send(:include, Extraction::LumberjackExtensions)
        # self._logger = Lumberjack::Logger.new(options)
        self._logger = logger_instance
      end

      def fake_logger
        Class.new{def method_missing(method,*args);end}.new
      end



    end





  end
end

