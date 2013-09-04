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
#
# === Copyright:
#
# Copyright (C) 2012 Corey Osman, unless otherwise noted.
#
class bmclib {
  case $::operatingsystem {
    'ubuntu': {
      $freeipmi = 'freeipmi-tools'
      $openipmi = 'openipmi'
    }
    default: {
      $freeipmi = 'freeipmi'
      $openipmi = 'OpenIPMI'
    }
  }

  package { 'ipmitool':
    ensure => latest,
    name   => 'ipmitool',
  }

  package { 'ipmidriver':
    ensure => latest,
    name   => $openipmi,
  }

  service { 'ipmi':
    ensure  => running,
    require => [ Package['ipmitool'], Package['ipmidriver'] ],
  }
}
