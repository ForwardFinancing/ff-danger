# frozen_string_literal: true

require_relative '../block_owner_rule'

module FfDanger
  class BlockOwnerRule
    class Scanner
      Candidate = Struct.new(:config, :path, :lines)

      def initialize(configs:, git:)
        @configs = configs
        @git     = git
      end

      include Enumerable

      def each
        return enum_for(:each) unless block_given?

        git.modified_files.each do |file, _acc|
          configs.each do |config|
            next unless config.watches?(file)

            each_candidate(config, file) { |candidate| yield(candidate) }
          end
        end
      end

      private

      attr_reader :configs, :git

      def each_candidate(config, file)
        changes = GitDiffParser::Patch.new(
          git.diff_for_file(file).patch
        ).changed_line_numbers

        # [1,2,3,5,6,7] => (1..3) (5..7)
        start = changes.first
        changes.each_with_index do |line, i|
          next if changes[i + 1] == line + 1

          candidate = Candidate.new(
            config,
            file,
            start..line
          )

          yield candidate

          start = changes[i + 1]
        end
      end
    end
  end
end
