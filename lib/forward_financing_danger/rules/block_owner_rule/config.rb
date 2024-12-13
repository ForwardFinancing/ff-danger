# frozen_string_literal: true

require_relative '../block_owner_rule'

module ForwardFinancingDanger
  class BlockOwnerRule
    class Config
      class ConfigurationError < StandardError; end

      def self.parse(json)
        new(
          directories: json.fetch('directories'),
          names:       json.fetch('names').map(&:to_sym),
          message:     ERB.new(json.fetch('message'))
        )
      rescue StandardError => e
        raise ConfigurationError, e.message
      end

      attr_reader :names

      def initialize(directories:, names:, message: nil)
        @directories = directories
        @names       = names
        @message     = message
      end

      def message(hit)
        @message.result_with_hash(description: hit.description)
      end

      def watches?(file)
        @directories.any? do |directory|
          # app/models should match inside engines
          file.include?(directory)
        end
      end
    end
  end
end
