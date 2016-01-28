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
class bmclib::ipmievd (
  $service_ensure = 'running',
  $manage_service = true,
){
  require 'bmclib'

  case $::osfamily {
    'Debian': {
      file { 'ipmievdconfig':
        ensure  => file,
        path    => '/etc/default/ipmievd',
        content => 'ENABLED=true',
      }
    }
    'RedHat': {
      file { 'ipmievdconfig':
        ensure => file,
        path   => '/etc/sysconfig/ipmievd',
      }
    }
    default: { }
  }

  if $manage_service {
    service { 'ipmievd':
      ensure     => 'running',
      enable     => true,
      hasrestart => true,
      hasstatus  => true,
      subscribe  => File['ipmievdconfig'],
    }
  }
}
