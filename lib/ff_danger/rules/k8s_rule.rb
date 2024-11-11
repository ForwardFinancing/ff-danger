# frozen_string_literal: true

require_relative './rule'

module FfDanger
  class K8sRule < FfDanger::Rule

    FILE_LIMIT = 500

    def check!
    end

    private

    def number_of_lines(path)
      File.read(path).each_line.count
    end

    def big_file_message(size)
      "Seems like you are touching the K8s file. Please contact the infra team."
    end
  end
end
