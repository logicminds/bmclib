#! /usr/bin/env rspec
require 'spec_helper'

provider_class = Puppet::Type.type(:bmc).provider(:ipmitool)


describe provider_class do

  let (:resource) { Puppet::Type.type(:bmc).new(:ip=> '192.168.1.34',
                                                :provider => 'ipmitool',
                                                :netmask => '255.255.255.0',
                                                :gateway => '192.168.1.1',
                                                :ipsource => 'dhcp',
                                                :provider => :ipmitool,
                                                :name => "test_bmc_device") }
  let (:provider) { described_class.new(resource) }



  it "should be an instance of Puppet::Type::Bmc::Ipmitool" do
    provider.must be_an_instance_of Puppet::Type::Bmc::Ipmitool
  end

end


