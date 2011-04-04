module Extraction
  module Attributes
    extend ActiveSupport::Concern

    included do
      self._attributes = []
    end

    module InstanceMethods

      def attributes
        self._attributes.inject({}) do |hash, attr|
          hash[attr.to_s] = send(attr)
          hash
        end
      end

      protected

      def clear_attribute(attribute)
        send("#{attribute}=", nil)
      end

      def attribute?(attribute)
        send(attribute).present?
      end

    end

    module ClassMethods

      def field(name, options = {})
        attr_accessor name
        define_attribute_methods [name]
        self._attributes += name
      end
      #alias :field :parse

      def attributes(*names)
        attr_accessor *names
        define_attribute_methods names
        self._attributes += names
      end
      #alias :fields :attributes

      def collect_attribute_names

      end



    end



  end
end

