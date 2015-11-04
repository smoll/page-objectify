require "page-objectify/version"
require "logger"

module PageObjectify
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
