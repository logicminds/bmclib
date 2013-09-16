#! /usr/bin/env rspec
require 'spec_helper'

provider_class = Puppet::Type.type(:bmcuser).provider(:ipmitool)

describe provider_class do

    let (:resource) { Puppet::Type.type(:bmcuser).new(
                                                  :provider => 'ipmitool',
                                                  :userpass => 'supersecret',
                                                  :privlevel => 'admin',
                                                  :name => "testuser") }
    let (:provider) { described_class.new(resource) }

  it "should be an instance of Puppet::Type::Bmcuser::Ipmitool" do
    provider.must be_an_instance_of Puppet::Type::Bmcuser::Ipmitool
    #
  end

end
