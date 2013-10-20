# Class: bmclib
#
# This module manages bmclib
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]
class bmclib (
  $service_ensure = 'running',
  $package_ensure = 'latest',
) {

  service { 'ipmi':
    ensure  => $service_ensure,
    require => [ Package["ipmitool"], 
                 Package["ipmidriver"] ]
  }

  case $::osfamily {
    'Debian': {
      $freeipmi = 'freeipmi-tools'
      $openipmi = 'openipmi'
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

}
