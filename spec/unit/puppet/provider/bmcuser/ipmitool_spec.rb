#! /usr/bin/env rspec
require 'spec_helper'
provider_class = Puppet::Type.type(:bmcuser).provider(:ipmitool)


describe provider_class do
  subject { provider_class }

  let (:resource) { Puppet::Type.type(:bmcuser).new(
      :provider => 'ipmitool',
      :userpass => 'supersecret',
      :privlevel => 'admin',
      :username => "testuser",
      :name => "testuser")}


  let (:provider) { described_class.new(resource) }
  let(:facts)do {:is_virtual => 'false'} end


  before :each do
    File.stubs(:exists?).returns(true)
    Puppet::Util.stubs(:which).with("ipmitool").returns("/bin/ipmitool")
    subject.stubs(:which).with("ipmitool").returns("/bin/ipmitool")

  end

  it "should be an instance of Puppet::Type::Bmcuser::ProviderIpmitool" do
    provider.must be_an_instance_of Puppet::Type::Bmcuser::ProviderIpmitool
    #
  end

end
