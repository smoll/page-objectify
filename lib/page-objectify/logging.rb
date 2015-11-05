require "logger"

module PageObjectify
  module Logging
    def logger
      Logging.logger
    end

    class << self
      attr_writer :logger

      def logger
        @logger ||= Logger.new($stdout).tap do |log|
          log.progname = self.name
          log.level = 2
        end
      end
    end
  end
end
