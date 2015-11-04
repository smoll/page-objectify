require "nokogiri"

module PageObjectify
  class Generator
    def initialize(page:, base:, file:)
      @page = page
      @base = base
      @file = file
      fail "@page must be a String! @page=#{@page.inspect}" unless @page.is_a?(String)
      fail "@base must be a String! @base=#{@base.inspect}" unless @base.is_a?(String)
    end

    def generate!
      after_navigation

      # Grab all nodes with non-empty HTML id
      @doc.xpath("//*[@id!='']").each do |node|

        # TODO: filter out nodes for which there is no PO accessor!

        @node_count += 1
      end

      PageObjectify.logger.debug "First node: #{@doc.xpath("//*[@id!='']").first.to_s.chomp}"
      PageObjectify.logger.debug "TOTAL NODES FOUND: #{@node_count}"

      # TODO: write to @ast, extract it out to its own class

      # TODO: write @ast to disk, based on @file path specified
    end

    private

    def after_navigation
      fail "@browser variable must be a Watir::Browser instance! @browser=#{@browser.inspect}" unless @browser.is_a?(Watir::Browser)
      fail "Cannot get current page HTML!" unless @browser.respond_to?(:html)
      @doc = Nokogiri::HTML(@browser.html)
      @node_count = 0
    end
  end
end
