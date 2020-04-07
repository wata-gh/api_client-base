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
            option.keys.each do |hash_key|
              keys << "#{hash_key}[#{fields_str(option[hash_key])}]"
            end
          end
        end
        keys.join(',')
      end
    end

    def self.included(base)
      base.extend ClassMethods
      base.class_eval {
        scope :paginate_all, -> {
          page = 1
          result = []
          loop do
            res = page(page).all
            result += res
            page = res.metadata[:next_page]
            break unless page
          end
          result
        }

        scope :q, -> (condition) {
          cond = {}
          condition.each do |k, v|
            cond["q[#{k}]"] = v
          end
          where(cond)
        }

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

        scope :order, -> (*orders) {
          orders_cond = []
          orders.each do |order|
            case order
            when Hash
              orders_cond << order.map {|k, v| "#{k} #{v}"}.join(',')
            when Array
              orders_cond << order.join(', ')
            else
              orders_cond << order
            end
          end
          where(order: orders_cond.join(', '))
        }
      }
    end
  end
end
