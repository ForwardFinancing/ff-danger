# frozen_string_literal: true

Dir.glob("#{__dir__}/rules/**/*.rb").each do |path|
  require path
end
