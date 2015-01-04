require 'rubygems'
require 'puppetlabs_spec_helper/module_spec_helper'
#at_exit { RSpec::Puppet::Coverage.report! }
RSpec.configure do |config|
  config.mock_with :rspec

end
