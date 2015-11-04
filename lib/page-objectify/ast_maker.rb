require "parser/current"

module PageObjectify
  module ASTMaker
    def s(type, *children)
      Parser::AST::Node.new(type, children)
    end
  end
end
