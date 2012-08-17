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
class bmclib {
	
bmc{"ipmidevice":
    provider => "freeipmi",
    ensure => enabled,
    vlanid => "1",
    ip => "192.168.1.22",
    subnet => "255.255.255.0",
    gateway => "192.168.1.1",
    bootdevice => "pxe",
    user1 => "admin",
    user1pass => "password",
    user1pass => "password",
    snmp => "public",


   }
bmcuser{"bmcuser"
   provider => "freeipmi",
   privlevel => "ADMIN|OPERATOR|USER|CALLBACK"
   ensure => enabled,
   username => "username",
   userpass => "userpass",
   usercert =>"certkey",
   force => true

}

case $::operatingsystem {
   "ubuntu": {
        $freeipmi = "freeipmi-tools"
        $openipmi = "openipmi"
    }
    default: {
        $freeipmi = "freeipmi"
        $openipmi = "OpenIPMI"
	}
  }

  package{"freeipmiprovider":
        ensure => latest,
        name => $freeipmi,
      }

package{"ipmitoolprovider":
        ensure => latest,
        name => "ipmitool",
      }

  package{"ipmidriver":
        ensure => latest,
        name => $openipmi,
  }

}
