#!/usr/bin/env rspec

require 'spec_helper'

describe 'bmclib', :type => 'class' do

  context 'on a RedHat osfamily' do
    let(:params) do
      {:package_ensure => 'present' }
    end
    let :facts do {
      :osfamily        => 'RedHat',
      :operatingsystem => 'RedHat'
    }
    end

    it { is_expected.to contain_package('ipmitool').with(
      :ensure => 'present'
    )}
    it { is_expected.to contain_package('ipmidriver').with(
      :ensure => 'present',
      :name   => 'OpenIPMI'
    )}
    it { is_expected.to contain_service('ipmi').with(
      :ensure     => 'running',
      :enable     => 'true',
      :hasrestart => 'true',
      :hasstatus  => 'true',
    )}
    it { is_expected.to contain_file('ipmiconfig').with(
      :ensure  => 'file',
      :path    => '/etc/sysconfig/ipmi',
    )}
  end

  context 'on a Debian osfamily' do
    let(:params) do
      {:package_ensure => 'present' }
    end
    let :facts do {
      :osfamily        => 'Debian',
      :operatingsystem => 'Debian'
    }
    end

    it { is_expected.to contain_package('ipmitool').with(
      :ensure => 'present'
    )}
    it { is_expected.to contain_package('ipmidriver').with(
      :ensure => 'present',
      :name   => 'openipmi'
    )}
    it { is_expected.to contain_service('openipmi').with(
      :ensure     => 'running',
      :enable     => 'true',
      :hasrestart => 'true',
      :hasstatus  => 'true',
    )}
    it { is_expected.to contain_file('ipmiconfig').with(
      :ensure  => 'file',
      :path    => '/etc/default/ipmi',
      :content => 'ENABLED=true',
    )}
  end

end
