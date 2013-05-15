
require 'rubygems'
require 'bundler/setup'

require 'rudelo'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.order = 'random'

end

require "parslet"
require "parslet/rig/rspec"
require 'parslet/convenience'
