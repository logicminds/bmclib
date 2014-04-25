#! /usr/bin/env ruby
require 'spec_helper'

describe Puppet::Type.type(:bmcuser) do
  [:name, :provider, :force].each do |param|
    it "should have a #{param} parameter" do
      Puppet::Type.type(:bmcuser).attrtype(param).should == :param
    end
  end

  [:username, :ensure, :userpass, :privlevel].each do |param|
    it "should have an #{param} property" do
      Puppet::Type.type(:bmcuser).attrtype(param).should == :property
    end
  end

  describe 'username property' do
     it 'should return the username' do
       user = Puppet::Type.type(:bmcuser).new(:name => "Stan", :ensure => :present, :username => 'stanuser')
       user.should(:username).should == 'stanuser'
     end
  end

  describe 'userpass property' do
     it 'should return the userpass' do
       user = Puppet::Type.type(:bmcuser).new(:name => "Stan", :ensure => :present, :userpass => 'secret')
       user.should(:userpass).should == 'secret'
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
       user = Puppet::Type.type(:bmcuser).new(:name => "Stan", :ensure => :present, :privlevel => 'admin')
       user.should(:privlevel).should == :admin
     end
  end

end