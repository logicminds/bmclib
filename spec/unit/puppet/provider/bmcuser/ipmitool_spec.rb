#! /usr/bin/env rspec
require 'spec_helper'
provider_class = Puppet::Type.type(:bmcuser).provider(:ipmitool)


describe provider_class do
  subject { provider_class }

  let (:resource) { Puppet::Type.type(:bmcuser).new(
      :provider => 'ipmitool',
      :userpass => 'supersecret',
      :privlevel => 'ADMIN',
      :username => "testuser",
      :name => "testuser")
  }
  let (:provider) { described_class.new(resource) }

  let(:facts)do {:is_virtual => 'false', :bmc_device_present => true} end


  before :each do
    File.stubs(:exists?).returns(true)
    Puppet::Util.stubs(:which).with("ipmitool").returns("/bin/ipmitool")
    subject.stubs(:which).with("ipmitool").returns("/bin/ipmitool")

  end

  it "should be an instance of Puppet::Type::Bmcuser::Provider::Ipmitool" do
    expect(provider).to be_an_instance_of Puppet::Type::Bmcuser::ProviderIpmitool
  end

  [:ADMIN, :USER, :OPERATOR, :CALLBACK, :ADMINISTRATOR, :NOACCESS].each do |priv|
    context "privilege for type #{priv} should be supported" do

      let (:resource) { Puppet::Type.type(:bmcuser).new(
        :provider => 'ipmitool',
        :userpass => 'supersecret',
        :privlevel => priv,
        :username => "testuser",
        :name => "testuser")
      }
    end
    let (:provider) { described_class.new(resource) }
    it { expect(provider).to be_an_instance_of Puppet::Type::Bmcuser::ProviderIpmitool }

  end
  context 'invalid privilege type' do
    let (:resource) { Puppet::Type.type(:bmcuser).new(
      :provider => 'ipmitool',
      :userpass => 'supersecret',
      :privlevel => 'blah',
      :username => "testuser",
      :name => "testuser")
    }
    let (:provider) { described_class.new(resource) }
    it { expect{ provider.to raise_error(Puppet::ResourceError)  } }

  end

end
