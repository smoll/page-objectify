module PageObjectify
  class Config
    attr_reader :page, :base, :file

    def initialize(**keywords)
      @page = keywords[:page]
      @base = keywords[:base]
      @file = keywords[:file]
      validate_configs
    end

    def validate_configs
      fail "@page must be a String! @page=#{@page.inspect}" unless @page.is_a?(String)
      fail "@base must be a String! @base=#{@base.inspect}" unless @base.is_a?(String)
      fail "@file must end with '.rb'! @file=#{@file.inspect}" unless @file.end_with?(".rb")
    end
  end
end
