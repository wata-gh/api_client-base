module MpdevClient
  class HttpError < Error
    def initialize(env)
      @env = env
    end

    def method
      @env[:method].to_s.upcase
    end

    def url
      @env[:url]
    end

    def status
      @env[:status]
    end

    def reason_phrase
      @env[:reason_phrase]
    end

    def request_headers
      @env[:request_headers]
    end

    def response_headers
      @env[:response_headers]
    end

    def body
      @env[:body]
    end

    def json_body
      JSON.parse(body)
    end
  end

  class BadRequestError < HttpError; end
  class UnauthorizedError < HttpError; end
  class ForbiddenError < HttpError; end
  class MethodNotAllowedError < HttpError; end
  class NotAcceptable < HttpError; end
  class Conflict < HttpError; end
  class InternalServerError < HttpError; end
  class BadGateway < HttpError; end
  class ServiceUnavailableError < HttpError; end
  class GatewayTimeoutError < HttpError; end

  class GarageParser < Her::Middleware::FirstLevelParseJSON
    def parse(body)
      res = super(body)
      if current_response_headers['x-list-totalcount']
        res[:metadata][:list_totalcount] = current_response_headers['x-list-totalcount'].to_i
        link = current_response_headers['link']
        if link
          res[:metadata][:link] = link
          link.split(',').each do |l|
            m = l.match(/<(.*)>.*rel=\"(.+?)\".*page=\"([0-9]+?)\"/)
            if m
              rel = m[2]
              res[:metadata]["#{rel}_path".to_sym] = m[1]
              res[:metadata]["#{rel}_page".to_sym] = m[3].to_i
              res[:metadata][:per_page] ||= m[1][/per_page=([0-9]+)/, 1]&.to_i
            end
          end
        end
      end
      res
    end

    def on_complete(env)
      clear_thread_local
      case env[:status]
      when 401
        Base.logger.error(env)
        raise UnauthorizedError.new(env)
      when 403
        Base.logger.error(env)
        raise ForbiddenError.new(env)
      when 405
        Base.logger.error(env)
        raise MethodNotAllowedError.new(env)
      when 406
        Base.logger.error(env)
        raise NotAcceptable.new(env)
      when 409
        Base.logger.error(env)
        raise Conflict.new(env)
      when 500
        Base.logger.error(env)
        raise InternalServerError.new(env)
      when 502
        Base.logger.error(env)
        raise BadGateway.new(env)
      when 503
        Base.logger.error(env)
        raise ServiceUnavailableError.new(env)
      when 504
        Base.logger.error(env)
        raise GatewayTimeoutError.new(env)
      else
        Base.logger.debug("[request ] #{env[:method].to_s.upcase} #{env[:url]} #{env[:request_headers]}")
        Base.logger.debug("[response] #{env[:status]} #{env[:reason_phrase]} #{env[:response_headers]}")
        Base.logger.debug("[body    ] #{env[:body]}")
        set_current_env(env)
        super
      end
    end

    private

    def clear_thread_local
      Thread.current[:mpdev_client_garage_parser] = {}
    end

    def thread_local
      Thread.current[:mpdev_client_garage_parser]
    end

    def set_current_env(env)
      thread_local[:current_env] = env
    end

    def current_env
      thread_local[:current_env]
    end

    def current_response_headers
      current_env[:response_headers]
    end
  end
end
