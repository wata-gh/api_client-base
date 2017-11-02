module MpdevClient
  class BadRequestError < Error; end
  class UnauthorizedError < Error; end
  class ForbiddenError < Error; end
  class MethodNotAllowedError < Error; end
  class InternalServerError < Error; end
  class ServiceUnavailableError < Error; end

  class GarageParser < Her::Middleware::FirstLevelParseJSON
    def on_complete(env)
      case env[:status]
      when 400
        Base.logger.error(env)
        raise BadRequestError
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
        super
      end
    end
  end
end
