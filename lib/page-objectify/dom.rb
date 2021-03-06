require "nokogiri"
require "page-object"
require "page-objectify/logging"

module PageObjectify
  class DOM
    include Logging

    attr_reader :tags_to_accessors, :input_types_to_accessors

    def initialize(html)
      @html = html
      @doc = Nokogiri::HTML(@html)
      @accessors = []
      @tags_to_accessors = {}
      @input_types_to_accessors = {}
      @types = %i(text password checkbox button image reset submit radio hidden file)
      @ignored_tags = %i(meta style body script thead tbody) # that could possibly have an HTML id

      generate_mapping
    end

    def to_accessors
      # Grab only nodes with non-empty HTML id
      @doc.xpath("//*[@id!='']").each do |node|
        accessor = accessor_for(node)
        @accessors << { accessor: accessor, id: node.attributes["id"].to_s } if accessor
      end
      logger.info "DOM nodes convertable to PageObject::Accessors: #{@accessors.count}"
      @accessors
    end

    private

    # Returns a String
    def accessor_for(node)
      tag = node.name.to_sym

      unless supported?(tag)
        logger.warn "Tag #{tag} is not supported! This may be a bug in the PageObjectify gem, please report it! :)" unless ignored?(tag)
        return nil
      end

      # check if node is ~ <input type="blah">
      if tag == :input
        type = node.attributes["type"].to_s.to_sym
        return @input_types_to_accessors[type]
      end
      @tags_to_accessors[tag]
    end

    def supported?(tag)
      return true if tag == :input
      return true if @tags_to_accessors.has_key?(tag)
      false
    end

    # Explicitly ignore tags like <meta>
    def ignored?(tag)
      @ignored_tags.include?(tag)
    end

    # From https://github.com/cheezy/page-object/wiki/Methods-for-HTML-Tags
    def generate_mapping
      type_map = PageObject::Elements.type_to_class
      tag_map  = PageObject::Elements.tag_to_class
      combined = type_map.merge(tag_map)

      combined.each do |key, value|
        @tags_to_accessors[key] = value.to_s.split('::').last.gsub(/([a-z])([A-Z])/, '\1_\2').downcase
      end

      @types.each do |type|
        @input_types_to_accessors[type] = @tags_to_accessors.delete(type)
      end

      # Fix for <input type="button"> and <button> duping each other
      @tags_to_accessors[:button] = "button"

      # Fix for https://github.com/smoll/page-objectify/issues/13
      [:h1, :h2, :h3, :h4, :h5, :h6].each { |k| @tags_to_accessors[k] = k.to_s }

      # Fix for https://github.com/smoll/page-objectify/issues/16
      @tags_to_accessors[:td] = "cell"
      @tags_to_accessors[:th] = "cell"
      @tags_to_accessors[:b] = "b"
      @tags_to_accessors.delete(:tr)
      @tags_to_accessors.delete(:option)
      @input_types_to_accessors[:checkbox] = "checkbox"

      logger.debug "TAGS_TO_ACCESSORS = #{@tags_to_accessors}"
      logger.debug "TYPES_TO_ACCESSORS = #{@input_types_to_accessors}"
    end
  end
end
