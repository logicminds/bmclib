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
class bmclib {
  case $::osfamily {
    'Debian': {
      $openipmi = 'openipmi'

      file { '/etc/default/ipmi':
        ensure  => 'present',
        content => 'ENABLED=true',
        notify  => Service['ipmi'],
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
      $openipmi = 'OpenIPMI'
    }
  }

  package { 'ipmitool':
    ensure => present,
  }

  package { 'ipmidriver':
    ensure => present,
    name   => $openipmi,
  }

  service { 'ipmi':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => [ Package['ipmitool'], Package['ipmidriver'], ],
  }
}
