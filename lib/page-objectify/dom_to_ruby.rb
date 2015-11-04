require "unparser"
require "page-objectify/ast_maker"
require "page-objectify/config"

module PageObjectify
  # Takes an Array of DOM nodes (Nokogiri::XML::Element objects)
  # and generates Ruby code (page class containing PageObject::Accessors)
  class DOMToRuby
    include ASTMaker

    # TODO: leverage PageObject to get this mapping programmatically?
    TAG_TO_ACCESSOR = {
      "a" => "link",
      "button" => "button"
    }

    def initialize(array, config)
      @array = array
      @config = config
    end

    # Generate Ruby source as a String
    def unparse
      tree = s(:class,
        *first_line,
        s(:begin, *accessors)
      )
      Unparser.unparse(tree)
    end

    private

    # Array of Parser::AST::Nodes, which represents the line:
    # "GeneratedPage < BasePage"
    def first_line
      [s(:const, nil, @config.page), s(:const, nil, @config.base)]
    end

    # Array of AST nodes, which represent lines that look like:
    # button(:submit, id: "submit")
    # button(:cancel, id: "cancel")
    def accessors
      res = []
      @array.each do |element|
        res << s(:send, nil, accessor_for(element.name).to_sym,
          s(:sym, element.attributes["id"].to_s.to_sym),
          s(:hash,
            s(:pair,
              s(:sym, :id),
              s(:str, element.attributes["id"].to_s)
            )
          )
        )
      end
      res
    end

    def accessor_for(tag)
      fail "Tag #{tag} is not supported! This may be a bug in the PageObjectify gem, please report it! :)" unless TAG_TO_ACCESSOR.has_key?(tag)
      TAG_TO_ACCESSOR[tag]
    end
  end
end
