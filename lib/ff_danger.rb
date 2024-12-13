# frozen_string_literal: true

require 'ff_danger/version'
require 'ff_danger/rules/rule.rb'
require 'ff_danger/rules/rules.rb'
Dir[File.join(__dir__, 'ff_danger/rules/mixins', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, 'ff_danger/rules', '*_rule.rb')].each { |file| require file }

module ForwardFinancingDanger
end
