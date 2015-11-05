require "nokogiri"
require "page-objectify/config"
require "page-objectify/dom"
require "page-objectify/dom_to_ruby"
require "page-objectify/logging"

module PageObjectify
  class Generator
    include Logging

    def initialize(**config)
      @config = Config.new(generator_class: self.class.to_s, **config)
    end

    def generate!
      parse_current_page

      @code = DOMToRuby.new(@dom, @config).unparse

      logger.debug "** BEGIN GENERATED CODE **"
      @code.each_line { |line| logger.debug line.chomp }
      logger.debug "** END GENERATED CODE **"

      File.open(@config.file, 'w') { |file| file.write(@code) }
    end

    private

    def parse_current_page
      fail "@browser variable must be a Watir::Browser instance! @browser=#{@browser.inspect}" unless @browser.is_a?(Watir::Browser)
      fail "Cannot get current page HTML!" unless @browser.respond_to?(:html)
      logger.info "About to parse HTML! Current URL: #{@browser.url}"
      @doc = Nokogiri::HTML(@browser.html)
      @dom = DOM.new(@doc)
    end
  end
end
