#! /usr/bin/env rspec
require 'spec_helper'
provider_class = Puppet::Type.type(:bmc).provider(:ipmitool)

describe provider_class do
  subject { provider_class }

  let(:facts)do {:is_virtual => 'false'} end

  let(:ipmitool_lan_print) do
     <<-OUTPUT
Set in Progress         : Set Complete
Auth Type Support       : NONE MD5 PASSWORD 
Auth Type Enable        : Callback : 
                        : User     : 
                        : Operator : 
                        : Admin    : MD5 
                        : OEM      : 
IP Address Source       : Static Address
IP Address              : 192.168.1.211
Subnet Mask             : 255.255.255.0
MAC Address             : 00:0e:0c:ea:92:a2
SNMP Community String   : 
IP Header               : TTL=0x40 Flags=0x40 Precedence=0x00 TOS=0x10
BMC ARP Control         : ARP Responses Enabled, Gratuitous ARP Disabled
Gratituous ARP Intrvl   : 2.0 seconds
Default Gateway IP      : 192.168.1.254
Default Gateway MAC     : 00:0e:0c:aa:8e:13
Backup Gateway IP       : 0.0.0.0
Backup Gateway MAC      : 00:00:00:00:00:00
RMCP+ Cipher Suites     : None
Cipher Suite Priv Max   : XXXXXXXXXXXXXXX
                        :     X=Cipher Suite Unused
                        :     c=CALLBACK
                        :     u=USER
                        :     o=OPERATOR
                        :     a=ADMIN
                        :     O=OEM
    OUTPUT
  end

  before :each do
    File.stubs(:exists?).returns(true)
    Puppet::Util.stubs(:which).with("ipmitool").returns("/bin/ipmitool")
    subject.stubs(:which).with("ipmitool").returns("/bin/ipmitool")
    subject.stubs(:ipmitoolcmd).with([ "lan", "print", "1"]).returns(ipmitool_lan_print)
    subject.stubs(:ipmitoolcmd).with([ "lan", "set", "1", "access", "on"]).returns(true)
    subject.stubs(:ipmitoolcmd).with([ "lan", "set", "1", "ipsrc", "dhcp" ]).returns(true)

    @resource =  Puppet::Type::Bmc.new( 
      { :ip       => '192.168.1.34',
        :provider => 'ipmitool',
        :netmask  => '255.255.255.0',
        :gateway  => '192.168.1.1',
        :ipsource => 'dhcp',
        :provider => 'ipmitool',
        :name     => "test_bmc_device"
      }
    )
    @provider = provider_class.new(@resource)
  end

  it "should be an instance of Puppet::Type::Bmc::Ipmitool" do
    @provider.should be_an_instance_of Puppet::Type::Bmc::ProviderIpmitool
  end

  describe 'install' do
    it 'enables the channel' do
      subject.expects(:ipmitoolcmd).with(["lan", "set", "1", "access", "on"])
      @provider.install
    end
  end

  describe 'ip' do
    it 'should set the ipsource' do
      subject.expects(:ipmitoolcmd).with([ "lan", "set", "1", "ipsrc", "dhcp" ])
      @provider.ipsource='dhcp'
    end
  end 

end


