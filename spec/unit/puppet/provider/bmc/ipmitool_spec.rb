#! /usr/bin/env rspec
require 'spec_helper'
provider_class = Puppet::Type.type(:bmc).provider(:ipmitool)

describe provider_class do
  subject { provider_class }

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
    allow(File).to receive(:exists?).and_return(true)
    allow(Puppet::Util).to receive(:which).with("ipmitool").and_return("/bin/ipmitool")
    allow(subject).to receive(:which).with("ipmitool").and_return("/bin/ipmitool")
    allow(subject).to receive(:ipmitoolcmd).with([ "lan", "print", "1"]).and_return(ipmitool_lan_print)
    allow(subject).to receive(:ipmitoolcmd).with([ "lan", "set", "1", "access", "on"]).and_return(true)
    allow(subject).to receive(:ipmitoolcmd).with([ "lan", "set", "1", "ipsrc", "dhcp" ]).and_return(true)
    allow(subject).to receive(:ipmitoolcmd).with([ "lan", "print", "2"]).and_return(ipmitool_lan_print)
    allow(subject).to receive(:ipmitoolcmd).with([ "lan", "set", "2", "access", "on"]).and_return(true)
    allow(subject).to receive(:ipmitoolcmd).with([ "lan", "set", "2", "ipsrc", "dhcp" ]).and_return(true)


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
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      before :each do
        Facter.clear
        facts.merge!(:bmc_device_present => true)
        facts.merge!(:is_virtual => false)
        facts.each do |k, v|
          allow(Facter).to receive(:fact).with(k).and_return Facter.add(k) { setcode { v } }
        end
      end

      it "should be an instance of Puppet::Type::Bmc::Ipmitool" do
        expect(@provider).to be_an_instance_of Puppet::Type::Bmc::ProviderIpmitool
      end
      it 'enables the channel' do
        expect(subject).to receive(:ipmitoolcmd).with(["lan", "set", "1", "access", "on"])
        @provider.install
      end

      it 'should set the ipsource' do
        expect(subject).to receive(:ipmitoolcmd).with([ "lan", "set", "1", "ipsrc", "dhcp" ])
        @provider.set_ipsource('dhcp')
      end

      describe 'HP device' do
        before :each do
           allow(Facter).to receive(:value).with(:manufacturer).and_return('HP')
        end

        it 'get ipsource' do
          expect(subject).to receive(:ipmitoolcmd).with([ "lan", "print", "2"])
          @provider.ipsource
        end

        it 'should set the ipsource' do
          expect(subject).to receive(:ipmitoolcmd).with([ "lan", "set", "2", "ipsrc", "dhcp" ])
          @provider.set_ipsource('dhcp')
        end

      end
    end
  end








end


