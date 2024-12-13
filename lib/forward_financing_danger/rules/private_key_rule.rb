# frozen_string_literal: true

require_relative './rule'

module ForwardFinancingDanger
  class PrivateKeyRule < ForwardFinancingDanger::Rule
    def check!
        changed_files.each do |path|
          lines_from_file(path).each do |line|
            if line.content.match(/BEGIN RSA PRIVATE KEY/)
                failure(private_key_error_message, file: path, line: line.number)
            end
          end
        end
      end

    private

    def private_key_error_message
      'This is a NO NO. Do not commit private keys to the repository.'
    end
  end
end