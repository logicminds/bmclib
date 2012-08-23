class bmclib::bmc_example {


  bmc{"ipmidevice":
        provider => "ipmitool",
        ensure => enabled,
        vlanid => "1",
        ip => "192.168.1.22",
        netmask => "255.255.255.0",
        gateway => "192.168.1.1",
        snmp => "public",
        force => true,
        require => Class["bmclib"]
       }

    bmcuser{"bmcuser"
       provider => "freeipmi",
       privlevel => "admin"
       ensure => enabled,
       username => "username",
       userpass => "userpass",
       force => true,
       require => Class["bmclib"]
    }
}
