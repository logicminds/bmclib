source 'https://rubygems.org'

group :development, :test do
  gem 'rake'
  gem 'puppetlabs_spec_helper', '>= 0.4.1', :require => false
  gem 'puppet-lint', '~> 0.3.2'
end

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', :require => false
end

# vim:ft=ruby
