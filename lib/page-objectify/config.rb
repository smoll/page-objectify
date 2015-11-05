module PageObjectify
  class Config
    attr_reader :page, :base, :file

    def initialize(**keywords)
      truncated = keywords[:generator_class].chomp("Generator")
      @page = keywords[:page] || truncated
      @base = keywords[:base] || "BasePage"
      @file = keywords[:file] || "#{underscorize(truncated)}.rb"
      validate_configs
    end

    def validate_configs
      fail "@page must be a String! @page=#{@page.inspect}" unless @page.is_a?(String)
      fail "@base must be a String! @base=#{@base.inspect}" unless @base.is_a?(String)
      fail "@file must end with '.rb'! @file=#{@file.inspect}" unless @file.end_with?(".rb")
    end

    private

    def underscorize(str)
      str.gsub(/::/, '/').
      gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
      gsub(/([a-z\d])([A-Z])/,'\1_\2').
      tr("-", "_").
      downcase
    end
  end
end
