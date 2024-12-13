# frozen_string_literal: true

require_relative './rule'

module ForwardFinancingDanger
  class NewSecretRule < ForwardFinancingDanger::Rule
    def check!
      changed_files.each do |file|
        # is file a secrets.yml file?
        if file.match(/secrets\.yml/)
            message(secret_message, file: file)
        end
      end
    end

    private

    def secret_message
      'It looks like you touched secrets.yml. Please add to ffk8s env or AWS secrets manager'
    end
  end
end
