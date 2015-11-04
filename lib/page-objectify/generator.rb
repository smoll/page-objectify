require "nokogiri"
require "page-objectify/config"
require "page-objectify/dom_to_ruby"

module PageObjectify
  class Generator
    def initialize(**config)
      @config = Config.new(**config)

      @nodes = []
    end

    def generate!
      parse_current_page

      # Grab all nodes with non-empty HTML id
      @doc.xpath("//*[@id!='']").each do |node|

        # TODO: filter out nodes for which there is no PO accessor!
        # Currently, all this does is only take links
        @nodes << node if node.name == "a"
      end

      PageObjectify.logger.debug "First node: #{@nodes.first.to_s.chomp}"
      PageObjectify.logger.debug "Total nodes: #{@nodes.count}"

      @code = dom_to_ruby

      PageObjectify.logger.debug "** BEGIN GENERATED CODE **"
      @code.each_line { |line| PageObjectify.logger.debug line.chomp }
      PageObjectify.logger.debug "** END GENERATED CODE **"

      File.open(@config.file, 'w') { |file| file.write(@code) }
    end

    private

    def dom_to_ruby
      @dom_to_ruby ||= DOMToRuby.new(@nodes, @config).unparse
    end

    def parse_current_page
      fail "@browser variable must be a Watir::Browser instance! @browser=#{@browser.inspect}" unless @browser.is_a?(Watir::Browser)
      fail "Cannot get current page HTML!" unless @browser.respond_to?(:html)
      @doc = Nokogiri::HTML(@browser.html)
    end
  end
end
