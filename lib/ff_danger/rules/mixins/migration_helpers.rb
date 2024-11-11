# frozen_string_literal: true

module MigrationHelpers

  def create_table?(migration)
    lines_from_file(migration).any? { |line| line.content.match?(/^(\s|\+{1}\s*|)create_table/) }
  end

  # Determines if migration contains a backfill.
  def backfill?(migration)
    updating_records?(migration) || inserting_records?(migration)
  end

  def updating_records?(migration)
    search_migration_for(migration: migration, regex_pattern: /(.*\.(update|update!|update_all))|(\s*update)/i)
  end

  def inserting_records?(migration)
    search_migration_for(migration: migration, regex_pattern: /(.*\.(create|create!|bulk_insert))|(\s*insert into)/i)
  end

  def has_disable_ddl_transaction?(path)
    search_migration_for(
      migration:     path,
      regex_pattern: /\s+disable_ddl_transaction(?:[^!]|$)/.freeze
    )
  end

  private

  def search_migration_for(migration:, regex_pattern:)
    lines_from_file(migration).any? do |line|
      line.content.match(regex_pattern)
    end
  end
end
