#!/usr/bin/env rspec

require 'spec_helper'

describe 'bmclib::ipmievd', :type => 'class' do

  context 'on a RedHat osfamily' do
    let(:params) {{}}
    let :facts do {
      :osfamily        => 'RedHat',
      :operatingsystem => 'RedHat'
    }
    end

    it { is_expected.to contain_service('ipmievd').with(
      :ensure     => 'running',
      :enable     => 'true',
      :hasrestart => 'true',
      :hasstatus  => 'true'
    )}
    it { is_expected.to contain_file('ipmievdconfig').with(
      :ensure  => 'file',
      :path    => '/etc/sysconfig/ipmievd',
    )}
  end

  context 'on a Debian osfamily' do
    let(:params) {{}}
    let :facts do {
      :osfamily        => 'Debian',
      :operatingsystem => 'Debian'
    }
    end

    it { is_expected.to contain_service('ipmievd').with(
      :ensure     => 'running',
      :enable     => 'true',
      :hasrestart => 'true',
      :hasstatus  => 'true'
    )}
    it { is_expected.to contain_file('ipmievdconfig').with(
      :ensure  => 'file',
      :path    => '/etc/default/ipmievd',
      :content => 'ENABLED=true',
    )}
  end

end
