#! /usr/bin/env rspec
require 'spec_helper'

provider_class = Puppet::Type.type(:bmcuser).provider(:ipmitool)

describe provider_class do
  subject { provider_class }


  let(:ipmitool_user_list_cmd) { ['/bin/ipmitool', ['user', 'list', '1']] }
  let(:ipmitool_user_list_output) { 'ID  Name	     Callin  Link Auth	IPMI Msg   Channel Priv Limit
2   ADMIN            false   false      true       ADMINISTRATOR' }
  let(:execute_options) { {:failonfail => true, :combine => true, :custom_environment => {} } }

  let (:resource) { Puppet::Type.type(:bmcuser).new(
      :provider => 'ipmitool',
      :userpass => 'supersecret',
      :privlevel => 'administrator',
      :username => "testuser",
      :name => "testuser")}

  let(:provider) { described_class.new(resource) }
  let(:facts)do {:is_virtual => 'false'} end


  before :each do
    File.stubs(:exists?).returns(true)
    Puppet::Util.stubs(:which).with("ipmitool").returns("/bin/ipmitool")
    subject.stubs(:which).with("ipmitool").returns("/bin/ipmitool")
    Puppet::Util::Execution.stubs(:execute).with(ipmitool_user_list_cmd, execute_options).returns(ipmitool_user_list_output)
  end

  it "should be an instance of Puppet::Type::Bmcuser::Provider::Ipmitool" do
    provider.should be_an_instance_of Puppet::Type::Bmcuser::ProviderIpmitool
    #
  end

  it "When enumerating instances" do
    expect(provider_class.userlist).to eq(
      {"ADMIN" =>
        {:priv => "administrator",
         :enabled=>true,
         :callin=>false,
         :name=>"ADMIN",
         :id=>2,
         :linkauth=>false
        }
      }
    )
  end

end
