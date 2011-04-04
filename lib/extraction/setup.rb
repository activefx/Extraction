module Extraction
  module Setup
    extend ActiveSupport::Concern

    included do
      class_attribute :_attributes
      attribute_method_prefix 'clear_'
      attribute_method_suffix '?'
      attr_reader :errors
    end

    module InstanceMethods

      def to_model
        self
      end

      def persisted?
        false
      end

    end


  end
end

