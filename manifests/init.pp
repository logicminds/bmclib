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

service{"ipmi":
    ensure => running,
    require => [Package["ipmitool"], Package["ipmidriver"]]

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


package{"ipmitool":
        ensure => latest,
        name => "ipmitool",
      }

  package{"ipmidriver":
        ensure => latest,
        name => $openipmi,
  }

}
