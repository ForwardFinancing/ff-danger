# frozen_string_literal: true

require_relative './rule'

module FfDanger
  class DeleteAllRule < FfDanger::Rule
    def check!
      changed_files.each do |path|
        lines_from_file(path).each do |line|
          if line.content.match(delete_all_regex)
            unless line.content.match(no_danger_comment_re)
              message(delete_all_warning, file: path, line: line.number)
            end
          end
        end
      end
    end

    private

    def delete_all_regex
      /\.delete_all/
    end

    def no_danger_comment_re
      /\#\s+(?:.*no\s+danger|safety\s+assured)/
    end

    def delete_all_warning
      'Looks like you made use of delete_all. This method skips callbacks so please make sure there are no destroy dependencies or callbacks like acts_as_paranoid for this object. If you find dependencies or callbacks, consider writing a method that still performs the delete_all but also handles the dependencies in bulk.'
    end
  end
end
