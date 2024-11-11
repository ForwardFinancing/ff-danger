# frozen_string_literal: true

require_relative './rule'

module FfDanger
  class DockerFileRule < FfDanger::Rule
    def check!
      changed_files.each do |file|
        # is file a Dockerfile?
        if file.end_with?('Dockerfile')
          message(docker_file_message, file: file, line: 1)
        end
      end
    end

    private

    def docker_file_message
      'Seems like you are touching the Dockerfile. Please let the infra team know.'
    end
  end
end
