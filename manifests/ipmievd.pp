# == Class: bmclib::ipmievd
#
# This class manages the ipmievd service to send events from the IPMI System
# Event Log (SEL) to syslog.
# Test events can be generated via "ipmitool event".
#
# === Actions:
#
# Starts the ipmievd service.
#
# === Requires:
#
#   Class['bmclib']
#
# === Authors:
#
# Mike Arnold <mike@razorsedge.org>
#
# === Copyright:
#
# Copyright (C) 2013 Mike Arnold, unless otherwise noted.
#
class bmclib::ipmievd {
  require 'bmclib'

  case $::osfamily {
    'Debian': {
      file { '/etc/default/ipmievd':
        ensure  => 'present',
        content => 'ENABLED=true',
        notify  => Service['ipmievd'],
      }
    }
    'RedHat': {
      file { '/etc/sysconfig/ipmievd':
        ensure  => 'present',
#        content => 'IPMIEVD_OPTIONS="sel pidfile=/var/run/ipmievd.pid"',
        notify  => Service['ipmievd'],
      }
    }
    default: { }
  }

  service { 'ipmievd':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
  }
}
