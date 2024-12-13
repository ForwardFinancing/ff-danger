# frozen_string_literal: true

require_relative './rule'
require_relative './mixins/migration_helpers'

module ForwardFinancingDanger
  class NewTableRule < ForwardFinancingDanger::Rule
    include MigrationHelpers

    MESSAGE = <<~MESSAGE
      When adding a new table, please be sure to:

      1. Check for indexes.
      2. Consult with FF DB/DevOps Team team.
    MESSAGE

    def check!
      puts "Checking for new tables..."
      if added_migrations.any? { |migration| create_table?(migration) }
        warning(MESSAGE)
      end
    end
  end
end
