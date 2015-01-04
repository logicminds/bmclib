[![Build Status](https://travis-ci.org/logicminds/bmclib.png)](https://travis-ci.org/logicminds/bmclib)

#bmclib

####Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with bmclib](#setup)
    * [What bmclib affects](#what-[bmclib]-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with bmclib](#beginning-with-[bmclib])
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

##Overview
The BMClib is a puppet module that lets you provision your ipmi devices using a native type. 


##Module Description
The bmclib puppet module provides a native type and provider that helps you provision your ipmi devices and users on your 
ipmi device.  It uses openipmi to configure your device which if performed on the system as root does not require any authentication.
Because no authentication is required, ipmi devices can be programmed automatically with puppet.
Additionally, I have provided several helpful custom facts that detail if the device is present and some of the networking
configuration around your bmc device.

##Setup

###What bmclib affects

* The impi device on your server, which you should only have one of.
* Installs openipmi and starts the openipmi service
* Note: Vitural Machines are not supported because they do not have any ipmi devices to configure.

###Setup Requirements

- Requires a BMC device compatible with IPMI specifications.
- ipmitool installed
- openimpi installed and running

###Beginning with bmclib

I have created a puppet class to assist with installing the openipmi driver and ipmitool, but your not required to use this
class if you already have something working. Without openipmi working on your puppet managed system, the facts and providers
will not be available.

```puppet
include 'bmclib'     
```

##Usage
```puppet
include 'bmclib'
```

```puppet
bmc { 'ipmidevice':
  ensure   => enabled,
  vlanid   => '1',
  ip       => '192.168.1.22',
  netmask  => '255.255.255.0',
  gateway  => '192.168.1.1',
  snmp     => 'public',
  force    => true,
  require  => Class['bmclib'],
}
```

```puppet
bmcuser { 'bmcuser'
  ensure    => enabled,
  privlevel => 'admin',
  username  => 'username',
  userpass  => 'userpass',
  force     => true,
  require   => Class['bmclib'],
}
```
##Reference

### Facts provided:

- bmc_gateway => 192.168.1.1
- bmc_ip => 192.168.1.41
- bmc_mac => 00:17:A4:49:AB:70
- bmc_subnet => 255.255.255.0
- bmc_device_present => false or true

```puppet 
   if not bmc_device_present {
      exec{"Purchase better hardware":
        command => 'echo "We need better hardware boss! | mail -s "help us!" boss@compan.com'
      }
   }
```
### Types Provided

- bmcuser  (adds user to bmc device)
- bmc      (configures bmc device on network)

### Providers Available
- ipmitool

### Parameters for bmc type

- provider: if left blank will default to ipmitool
- ensure : enabled, present, disabled
- vlanid :the vlan the bmc interface should communicate on (optional)
- ip: the ip address of the bmc device (required)
- netmask:the netmask of the bmc device (required)
- gateway: the gateway of the bmc device (required)
- snmp:the snmp public community string for the bmc device
- force: force set the parameters during each puppet run

### Parameters for bmcuser type

- provider: if left blank will default to ipmitool
- ensure : enabled, present, disabled
- privlevel :the privilage level of the bmc user
- username: username of bmc user to add
- userpass: the password of the bmc user to add
- force: force set the parameters during each puppet run


##Limitations
Works on *nix systems or whatever can run openipmi and ipmitool.
Not all linux operating systems are listed in the support metadata.  YMMV.

## Contributors
* Corey Osman <corey@logicminds.biz>  (Original Author)
* Mike Arnold
* Kyle Anderson
* Tomas Doran
* Barak Korren
* Fred Hatfull
* James McGuinness

##Development

### Testing ###

To begin you need to run:

- rake spec