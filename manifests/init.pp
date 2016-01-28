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
  $manage_service = true,
  $package_ensure = 'latest',
  $manage_package = true
) {

  case $::osfamily {
    'Debian': {
      $freeipmi = 'freeipmi-tools'
      $openipmi = 'openipmi'
      $service_name = 'openipmi'

      file { 'ipmiconfig':
        ensure  => file,
        path    => '/etc/default/ipmi',
        content => 'ENABLED=true',
      }
    }
    'RedHat': {
      $openipmi = 'OpenIPMI'
      $service_name = 'ipmi'

      file { 'ipmiconfig':
        ensure => file,
        path   => '/etc/sysconfig/ipmi',
      }
    }
    default: {
      $freeipmi = 'freeipmi'
      $openipmi = 'OpenIPMI'
      $service_name = 'ipmi'
    }
  }

  if $manage_package {
    package { 'ipmitool':
      ensure => $package_ensure,
      name   => 'ipmitool',
    }

    package { 'ipmidriver':
      ensure => $package_ensure,
      name   => $openipmi,
    }

    # See resource collection
    # https://docs.puppetlabs.com/puppet/latest/reference/lang_collectors.html
    Service <| $title == $service_name |> {
      subscribe +> [Package['ipmitool'], Package['ipmidriver']],
    }
  }

  if $manage_service {
    service { $service_name:
      ensure     => $service_ensure,
      enable     => true,
      hasrestart => true,
      hasstatus  => true,
      subscribe  => File['ipmiconfig'],
    }
  }
}
