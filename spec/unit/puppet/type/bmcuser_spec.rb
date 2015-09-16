#! /usr/bin/env ruby
require 'spec_helper'

describe Puppet::Type.type(:bmcuser) do
  [:name, :provider, :force].each do |param|
    it "should have a #{param} parameter" do
      expect(Puppet::Type.type(:bmcuser).attrtype(param)).to eq(:param)
    end
  end

  [:username, :ensure, :userpass, :privlevel].each do |param|
    it "should have an #{param} property" do
      expect(Puppet::Type.type(:bmcuser).attrtype(param)).to eq(:property)
    end
  end

  describe 'username property' do
     it 'should return the username' do
       user = Puppet::Type.type(:bmcuser).new(:name => "Stan", :ensure => :present, :username => 'stanuser')
       expect(user.should(:username)).to eq('stanuser')
     end
  end

  describe 'userpass property' do
     it 'should return the userpass' do
       user = Puppet::Type.type(:bmcuser).new(:name => "Stan", :ensure => :present, :userpass => 'secret')
       expect(user.should(:userpass)).to eq('secret')
     end
  end

  describe 'force param' do
     it 'should return the force value' do
       Puppet::Type.type(:bmcuser).new(:name => "Stan", :ensure => :present, :force => true)
       Puppet::Type.type(:bmcuser).new(:name => "Stan", :ensure => :present, :force => false)
     end
  end

  describe 'privlevel property' do
     it 'should return the privlevel' do
       user = Puppet::Type.type(:bmcuser).new(:name => "Stan", :ensure => :present, :privlevel => 'ADMIN')
       expect(user.should(:privlevel)).to eq(:ADMIN)
     end
  end

end