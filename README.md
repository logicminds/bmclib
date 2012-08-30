## BMCLib

### About

The BMClib is a puppet library that provides bmc related facts as well as a bmc type and bmcuser type.
Currently the only provider available is ipmitool.  However, in the future additional provider types will include
freeipmi, hponcfg, and other oem related tools.


### Facts provided:

bmc_gateway => 192.168.1.1
bmc_ip => 192.168.1.41
bmc_mac => 00:17:a4:49:ab:70
bmc_subnet => 255.255.255.0

### Types Provided

- bmcuser  (adds user to bmc device)
- bmc      (configures bmc device on network)

### Providers Available
- ipmitool

### Example Puppet Manifest Usage:

```

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
       provider => "ipmitool",
       privlevel => "admin"
       ensure => enabled,
       username => "username",
       userpass => "userpass",
       force => true,
       require => Class["bmclib"]
    }

```

#### Parameters for bmc type

- provider: if left blank will default to ipmitool
- ensure : enabled, present, disabled
- vlanid :the vlan the bmc interface should communicate on (optional)
- ip: the ip address of the bmc device (required)
- netmask:the netmask of the bmc device (required)
- gateway: the gateway of the bmc device (required)
- snmp:the snmp public community string for the bmc device
- force: force set the parameters during each puppet run

#### Parameters for bmcuser type

- provider: if left blank will default to ipmitool
- ensure : enabled, present, disabled
- privlevel :the privilage level of the bmc user
- username: username of bmc user to add
- userpass: the password of the bmc user to add
- force: force set the parameters during each puppet run

