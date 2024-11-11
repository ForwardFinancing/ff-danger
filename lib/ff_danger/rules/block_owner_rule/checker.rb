# frozen_string_literal: true

require_relative '../../github_remote'
require_relative '../../scope_expander'

require_relative './config'
require_relative './scanner'

module FfDanger
  class BlockOwnerRule
    class Checker
      Alert = Struct.new(:message, :path, :line)

      def self.for(config:, git:, github:)
        new(
          remote:  GithubRemote.for(github),
          scanner: Scanner.new(
            configs: [Config.parse(config)],
            git:     git
          )
        )
      end

      def initialize(remote:, scanner:, expander: ScopeExpander.new)
        @remote   = remote
        @scanner  = scanner
        @expander = expander
      end

      def alerts
        scanner.each_with_object([]) do |candidate, alerts|
          config = candidate.config

          found = expander.find(
            contents: remote.fetch(candidate.path),
            names:    config.names,
            lines:    candidate.lines
          )

          next unless found

          alerts << Alert.new(
            config.message(found),
            candidate.path,
            candidate.lines.last
          )
        end
      end

      private

      attr_reader :expander, :remote, :scanner
    end
  end
end
