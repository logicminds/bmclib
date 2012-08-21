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
    provider => "ipmitool",
    ensure => enabled,
    vlanid => "1",
    ip => "192.168.1.22",
    netmask => "255.255.255.0",
    gateway => "192.168.1.1",
    snmp => "public",


   }

bmcuser{"bmcuser"
   provider => "freeipmi",
   privlevel => "ADMIN|OPERATOR|USER|CALLBACK"
   ensure => enabled,
   username => "username",
   userpass => "userpass",
   force => true

}

service{"ipmi":
    ensure => running,
    require => Pakcage["ipmi"]

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
