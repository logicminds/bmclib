#! /usr/bin/env ruby

require 'spec_helper'

describe Puppet::Type.type(:bmc) do
  [:name, :provider].each do |param|
    it "should have a #{param} parameter" do
      Puppet::Type.type(:bmc).attrtype(param).should == :param
    end
  end

  [:ipsource,:ensure, :ip, :netmask, :gateway, :vlanid].each do |param|
    it "should have an #{param} property" do
      Puppet::Type.type(:bmc).attrtype(param).should == :property
    end
  end

end

describe Puppet::Type.type(:bmc), "when validating attribute values" do

  it "should support :present as a value to :ensure" do
    Puppet::Type.type(:bmc).new(:name => "device1", :ensure => :present)
  end

  it "should support :absent as a value to :ensure" do
    Puppet::Type.type(:bmc).new(:name => "device1", :ensure => :absent)
  end

  describe 'ipsource property' do
     it 'should support :dhcp as a value' do
       Puppet::Type.type(:bmc).new(:name => "device1", :ensure => :present, :ipsource => 'dhcp')
     end
     it 'should support :static as a value' do
       Puppet::Type.type(:bmc).new(:name => "device1", :ensure => :present, :ipsource => 'static')
     end
     it 'should default to dhcp' do
       type = Puppet::Type.type(:bmc).new(:name => "device1", :ensure => :present)
       type.should(:ipsource).should == :dhcp
     end
  end

  describe 'ip property' do
     it 'should validate and pass if valid ipaddress' do
       Puppet::Type.type(:bmc).new(:name => "device1", :ensure => :present, :ip => '192.168.1.1')
     end

     it 'should raise ArgumentError if not valid ipaddress' do
       expect{Puppet::Type.type(:bmc).new(:name => "device1", :ensure => :present, :ip => '290.221.223.1')}.to raise_error
     end

  end

  describe 'netmask property' do
    it 'should validate and pass if valid netmask' do
      Puppet::Type.type(:bmc).new(:name => "device1", :ensure => :present, :netmask => '192.168.1.1')
    end

    it 'should raise ArgumentError if not valid netmask' do
      expect{Puppet::Type.type(:bmc).new(:name => "device1", :ensure => :present, :netmask => '290.221.223.1')}.to raise_error
    end
  end

  describe 'gateway property' do
    it 'should validate and pass if valid gateway' do
      Puppet::Type.type(:bmc).new(:name => "device1", :ensure => :present, :gateway => '192.168.1.1')
    end

    it 'should raise ArgumentError if not valid gateway' do
      expect{Puppet::Type.type(:bmc).new(:name => "device1", :ensure => :present, :gateway => '290.221.223.1')}.to raise_error
    end
  end

  describe 'vlanid property' do
    it 'should validate and pass if valid vlanid' do
      Puppet::Type.type(:bmc).new(:name => "device1", :ensure => :present, :vlanid => '1')
    end
    it 'should validate and pass if valid vlanid' do
      Puppet::Type.type(:bmc).new(:name => "device1", :ensure => :present, :vlanid => '4094')
    end
    it 'should raise ArgumentError if not valid vlanid' do
      expect{Puppet::Type.type(:bmc).new(:name => "device1", :ensure => :present, :vlanid => '9000')}.to raise_error
    end
  end

end