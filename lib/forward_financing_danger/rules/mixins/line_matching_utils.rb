# frozen_string_literal: true

module LineMatchingUtils
  def match_in_proximity(lines:, pattern_1:, pattern_2:, lines_before: 0, lines_after: 0)
    matching_lines = []
    lines.select { |line| line.content.match(pattern_1) }.each do |line|
      scan_start = [line.number - lines_before, 0].max
      scan_end = line.number + lines_after
      lines_to_scan = lines.select { |line| (scan_start..scan_end).cover?(line.number) }
      matching_lines << line.number if lines_to_scan.any? { |line| line.content.match(pattern_2) }
    end
    matching_lines
  end
end
