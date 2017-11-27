require 'logger'
require 'her'
require 'mpdev_client/base/version'
require 'mpdev_client/error'
require 'mpdev_client/garage_concern'
require 'mpdev_client/garage_parser'

module MpdevClient
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
