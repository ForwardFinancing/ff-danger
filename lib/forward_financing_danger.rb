# frozen_string_literal: true

require 'forward_financing_danger/version'
require 'forward_financing_danger/rules/rule.rb'
require 'forward_financing_danger/rules/rules.rb'
Dir[File.join(__dir__, 'forward_financing_danger/rules/mixins', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, 'forward_financing_danger/rules', '*_rule.rb')].each { |file| require file }

module ForwardFinancingDanger
end
