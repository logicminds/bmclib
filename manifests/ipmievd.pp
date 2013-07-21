# == Class: bmclib::ipmievd
#
# This class manages the ipmievd service.
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

  if $::osfamily == 'Debian' {
    file { '/etc/default/ipmievd':
      ensure  => 'present',
      content => 'ENABLED=true',
      notify  => Service['ipmievd'],
    }
  } elsif $::osfamily == 'RedHat' {
    file { '/etc/sysconfig/ipmievd':
      ensure  => 'present',
#      content => 'IPMIEVD_OPTIONS="sel pidfile=/var/run/ipmievd.pid"',
      notify  => Service['ipmievd'],
    }
  }

  service { 'ipmievd':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
  }
}
