# frozen_string_literal: true

require_relative './ast_stack'

module FfDanger
  class ScopeExpander
    class Matcher
      attr_reader :name

      def initialize(name:)
        @name = name
      end
    end

    class InstanceMethod < Matcher
      def description
        "def #{name}"
      end

      def matches?(ast)
        ast.type == :def && ast.children[0] == name
      end
    end

    class ClassMethod < Matcher
      def description
        "def self.#{name}"
      end

      def matches?(ast)
        ast.type == :defs && ast.children[0].type == :self && ast.children[1] == name
      end
    end

    class Scope < Matcher
      def description
        "scope :#{name}"
      end

      def matches?(ast)
        ast.type == :send && ast.children[1] == :scope && ast.children[2].children[0] == name
      end
    end

    def initialize
      @matchers = [InstanceMethod, ClassMethod, Scope]
    end

    def find(contents:, names:, lines:)
      handlers = names.flat_map do |name|
        matchers.map do |matcher|
          matcher.new(name: name)
        end
      end

      ASTStack.new(contents, lines).each do |ast|
        handlers.each do |handler|
          return handler if handler.matches?(ast)
        end
      end
      nil
    end

    private

    attr_reader :matchers
  end
end
