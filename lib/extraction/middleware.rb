module Extraction
  module Middleware
    extend ActiveSupport::Concern

    included do
      class_eval do

        class Middleware

          def request(head, body)
            [head, body]
          end

          def response(resp)
            extractor = /.+(?=::Middleware)/.match(self.class.to_s).to_s
            extractor_class = extractor.classify
            resp.response = extractor_class.new(resp.response).
                              send(extractor_class._middleware_response)
          end

        end

      end
    end

  end
end

