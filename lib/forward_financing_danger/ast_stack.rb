# frozen_string_literal: true

require 'parser/current'

module ForwardFinancingDanger
  class ASTStack
    def initialize(text, lines)
      @ast   = Parser::CurrentRuby.parse(text)
      @lines = lines

      build
      freeze
    end

    include Enumerable

    def each
      return enum_for(:each) unless block_given?

      nodes.each { |node| yield(node) }
    end

    private

    attr_reader :ast, :lines, :nodes

    def build
      @nodes = []

      node = ast
      while node
        @nodes.unshift(node)
        node = node.children.find do |child|
          next unless child.respond_to?(:loc)

          loc = child.loc
          next unless loc.expression

          loc.first_line <= lines.first && loc.last_line >= lines.last
        end
      end
    end
  end
end
