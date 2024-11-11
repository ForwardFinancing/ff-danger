# frozen_string_literal: true

require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/object/blank'
require 'git_diff_parser'

module FfDanger
  class ConfigError < StandardError; end

  class Rule
    attr_accessor :handler

    def initialize(handler=nil, config=nil)
      @handler = handler
      @config = config
    end

    def name
      self.class.name
    end

    private

    attr_reader :config

    delegate :added_files, :diff, :diff_for_file, :lines_of_code, :modified_files, :renamed_files, to: :git
    delegate :branch_for_head, :branch_for_base, :pr_author, :pr_labels, :pr_body, to: :github
    delegate :validate_swagger_file, to: :swagger_gate
    delegate(
      :git,
      :github,
      :status_report,
      :swagger_gate,
      to: :handler
    )

    def failure(message, file: nil, line: nil)
      handler.failure("#{self.class.name}: #{message}", file: file, line: line)
    end

    def message(message, file: nil, line: nil)
      handler.message("#{self.class.name}: #{message}", file: file, line: line)
    end

    def warn(message, file: nil, line: nil)
      handler.warn("#{self.class.name}: #{message}", file: file, line: line)
    end

    def load_message_from_config
      config[:message]
    end

    def changed_files
      added_files + modified_files
    end

    def added_and_moved_files
      added_files + renamed_files.map { |file| file[:after] }
    end

    def changed_lines
      lines_from_files(changed_files)
    end

    def all_lines_safe_comments?
      safe_comment_regex = %r{^(\+\s*[\/|#]((?!frozen_string_literal).)*$)}
      empty_line_regex = %r{^\+\s*$}
      changed_lines.all? { |line| line.content.match(safe_comment_regex) || line.content.match(empty_line_regex) }
    end

    def lines_from_file(filename)
      diff_from_file(filename).changed_lines
    end

    def removed_lines_from_file(filename)
      diff_from_file(filename).removed_lines
    end

    def diff_from_file(filename)
      GitDiffParser::Patch.new(git.diff_for_file(filename).patch)
    end

    def lines_from_files(filenames)
      filenames.flat_map { |filename| lines_from_file(filename) }
    end

    def removed_lines_from_files(filenames)
      filenames.flat_map { |filename| removed_lines_from_file(filename) }
    end

    def added_migrations
      @added_migrations ||=
        (all_added_migrations - added_generated_bigint_migrations)
    end

    def all_added_migrations
      @all_added_migrations ||= added_files_matching(%r{db/migrate})
    end

    def all_sidekiq
      @all_sidekiq ||= added_files_matching(%r{app/workers})
    end

    def added_generated_bigint_migrations
      @added_generated_bigint_migrations ||=
        added_files_matching(%r{db/migrate/\d+_change_.*_table.*_to_bigints?.*\.rb$})
    end

    def files_matching(files, matcher)
      files.select { |filename| filename.match(matcher) }
    end

    def added_files_matching(matcher)
      files_matching(added_files, matcher)
    end

    def modified_files_matching(matcher)
      files_matching(modified_files, matcher)
    end

    def changed_files_matching(matcher)
      files_matching(changed_files, matcher)
    end

    def added_and_moved_files_matching(matcher)
      files_matching(added_and_moved_files, matcher)
    end

    def file_stats
      diff.stats.fetch(:files)
    end

    def defined_config
      {}
    end

    def validate_config
      if @config && defined_config.empty?
        raise ConfigError, "#{self.class} received config #{@config} but no defined_config is declared"
      end

      missing_values = []

      defined_config.keys.each do |k|
        missing_values << k if defined_config.dig(k).nil? || defined_config.dig(k).empty?
      end

      unless missing_values.empty?
        raise ConfigError, "#{@config} for #{self.class} is lacking the following values: #{missing_values}"
      end
    end
  end
end
