# == Class: bmclib
#
# This class manages the IPMI service which allows the system to communicate
# with the BMC.
#
# === Actions:
#
# Installs the OpenIPMI CLI tools and daemon.
# Starts the ipmi daemon.
#
# === Requires:
#
# Nothing
#
# === Authors:
#
# Corey Osman <corey@logicminds.biz>
# Mike Arnold <mike@razorsedge.org>
#
# === Copyright:
#
# Copyright (C) 2012 Corey Osman, unless otherwise noted.
# Copyright (C) 2013 Mike Arnold, unless otherwise noted.
#
# [Remember: No empty lines between comments and class definition]
class bmclib (
  $service_ensure = 'running',
  $package_ensure = 'latest'
) {

  case $::osfamily {
    'Debian': {
      $freeipmi = 'freeipmi-tools'
      $openipmi = 'openipmi'

      file { '/etc/default/ipmi':
        ensure => 'present',
        notify => Service['ipmi'],
        content => 'ENABLED=true',
      }
    }
    'RedHat': {
      $openipmi = 'OpenIPMI'

      file { '/etc/sysconfig/ipmi':
        ensure => 'present',
        notify => Service['ipmi'],
      }
    }
    default: {
      $freeipmi = 'freeipmi'
      $openipmi = 'OpenIPMI'
    }
  }

  package { 'ipmitool':
    name   => 'ipmitool',
    ensure => $package_ensure,
  }

  package { 'ipmidriver':
    name   => $openipmi,
    ensure => $package_ensure,
  }

  service { 'ipmi':
    ensure     => $service_ensure,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => [ Package['ipmitool'], Package['ipmidriver']],
  }
}
