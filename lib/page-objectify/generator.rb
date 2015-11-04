require "nokogiri"
require "page-objectify/config"
require "page-objectify/dom"
require "page-objectify/dom_to_ruby"

module PageObjectify
  class Generator
    def initialize(**config)
      @config = Config.new(**config)
    end

    def generate!
      parse_current_page

      @code = DOMToRuby.new(@dom, @config).unparse

      PageObjectify.logger.debug "** BEGIN GENERATED CODE **"
      @code.each_line { |line| PageObjectify.logger.debug line.chomp }
      PageObjectify.logger.debug "** END GENERATED CODE **"

      File.open(@config.file, 'w') { |file| file.write(@code) }
    end

    private

    def parse_current_page
      fail "@browser variable must be a Watir::Browser instance! @browser=#{@browser.inspect}" unless @browser.is_a?(Watir::Browser)
      fail "Cannot get current page HTML!" unless @browser.respond_to?(:html)
      @doc = Nokogiri::HTML(@browser.html)
      @dom = DOM.new(@doc)
    end
  end
end
