# frozen_string_literal: true

require_relative './rule'

module FfDanger
  class BigFileRule < FfDanger::Rule

    FILE_LIMIT = 500

    def check!
      changed_files.each do |path|
        # is file more than 1000 lines?
        file_size = number_of_lines(path)
        if file_size > FILE_LIMIT
          message(big_file_message(file_size), file: path, line: 1)
        end
      end
    end

    private

    def number_of_lines(path)
      File.read(path).each_line.count
    end

    def big_file_message(size)
      "Seems like this file is too big. It's #{size} lines long. Consider splitting it into smaller files."
    end
  end
end
