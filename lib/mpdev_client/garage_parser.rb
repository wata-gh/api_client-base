module MpdevClient
  class BadRequestError < Error; end
  class UnauthorizedError < Error; end
  class ForbiddenError < Error; end
  class MethodNotAllowedError < Error; end
  class InternalServerError < Error; end
  class ServiceUnavailableError < Error; end

  class GarageParser < Her::Middleware::FirstLevelParseJSON
    def parse(body)
      res = super(body)
      if current_response_headers['x-list-totalcount']
        res[:metadata][:list_totalcount] = current_response_headers['x-list-totalcount'].to_i
      end
      res
    end

    def on_complete(env)
      clear_thread_local
      case env[:status]
      when 401
        Base.logger.error(env)
        raise UnauthorizedError
      when 403
        Base.logger.error(env)
        raise ForbiddenError
      when 405
        Base.logger.error(env)
        raise MethodNotAllowedError
      when 500
        Base.logger.error(env)
        raise InternalServerError
      when 503
        Base.logger.error(env)
        raise ServiceUnavailableError
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
