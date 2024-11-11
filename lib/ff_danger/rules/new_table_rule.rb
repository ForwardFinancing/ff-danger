# frozen_string_literal: true

require_relative './rule'
require_relative './mixins/migration_helpers'

module FfDanger
  class NewTableRule < FfDanger::Rule
    include MigrationHelpers

    MESSAGE = <<~MESSAGE
      When adding a new table, please be sure to:

      1. Check for indexes.
      2. Consult with FF DB team.
    MESSAGE

    def check!
      if added_migrations.any? { |migration| create_table?(migration) }
        warning(MESSAGE)
      end
    end
  end
end
