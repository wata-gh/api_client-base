module MpdevClient
  module GarageConcern
    class NotFoundError < MpdevClient::Error; end

    module ClassMethods
      def find_by!(*args)
        res = find_by(*args)
        raise NotFoundError unless res
        res
      end

      def fields_str(*options)
        keys = []
        options.flatten.each do |option|
          case option
          when Symbol, String
            keys << option
          when Hash then
            hash_key = option.keys.first
            keys << "#{hash_key}[#{fields_str(option[hash_key])}]"
          end
        end
        keys.join(',')
      end
    end

    def self.included(base)
      base.extend ClassMethods
      base.class_eval {
        scope :geometory, -> (image, options) {
          params = {}
          options.keys.each do |key|
            params["geometory[#{image}][#{key}]"] = options[key]
          end
          where(params)
        }

        scope :fields, -> (*options) {
          where(fields: base.fields_str(options))
        }

        scope :page, -> (page) {
          page ? where(page: page) : all
        }

        scope :per, -> (per) {
          per_page(per)
        }

        scope :per_page, -> (per_page) {
          per_page ? where(per_page: per_page) : all
        }
      }
    end
  end
end
