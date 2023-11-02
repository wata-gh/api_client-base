require 'logger'
require 'her'
require 'api_client/base/version'
require 'api_client/error'
require 'api_client/garage_concern'
require 'api_client/garage_parser'

module ApiClient
  module Base
    def self.logger
      @logger ||= if defined?(Rails)
        Rails.logger
      else
        $stdout.sync = true
        Logger.new($stdout).tap do |l|
          l.level = Logger::INFO
        end
      end
    end
  end
end
