# frozen_string_literal: true

require 'active_support/core_ext/hash/indifferent_access'

module FfDanger
  class Rules
    def initialize(handler, included_rules=[], rules_config={})
      @handler = handler
      @rules   = rules || build_rules(included_rules, rules_config.transform_keys(&:to_sym))
    end

    include Enumerable

    def each
      return enum_for(:each) unless block_given?

      rules.each { |rule| yield rule }
    end

    def length
      rules.length
    end

    def check!
      each do |rule|
        begin
          rule.check!
        rescue StandardError => e
          handler.warn(
            <<~WARNING
              Danger failed to run #{rule.name} (#{e.class.inspect}: #{e.message}).
            WARNING
          )
        end
      end
    end

    private

    def build_rules(included, configs)
      included.map do |name_or_rule|
        name, config = rule_config(name_or_rule, configs)
        Module.const_get(name).new(handler, config.with_indifferent_access)
      end
    end

    def rule_config(name_or_rule, rules_config)
      case name_or_rule
      when String, Symbol
        name = name_or_rule
        rule = rules_config.fetch(name_or_rule.to_s.split('::').last.to_sym, {})
      when Hash
        name, rule = name_or_rule.first
      else
        raise NotImplementedError, "Can't derive rule from #{name_or_rule.class.name}: #{name_or_rule}"
      end
      [name, rule]
    end

    attr_reader :handler, :rules
  end
end
