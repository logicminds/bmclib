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
    it { is_expected.to contain_file('/etc/sysconfig/ipmievd').with(
      :ensure  => 'present',
      :path    => '/etc/sysconfig/ipmievd',
#      :content => 'IPMIEVD_OPTIONS="sel pidfile=/var/run/ipmievd.pid"',
      :notify  => 'Service[ipmievd]'
    )}
#    it 'should contain File[/etc/sysconfig/ipmievd] with contents "IPMIEVD_OPTIONS="sel pidfile=/var/run/ipmievd.pid""' do
#      verify_contents(subject, '/etc/sysconfig/ipmievd', [
#        'IPMIEVD_OPTIONS="sel pidfile=/var/run/ipmievd.pid"',
#      ])
#    end
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
    it { is_expected.to contain_file('/etc/default/ipmievd').with(
      :ensure  => 'present',
      :path    => '/etc/default/ipmievd',
      :content => 'ENABLED=true',
      :notify  => 'Service[ipmievd]'
    )}
  end

end
