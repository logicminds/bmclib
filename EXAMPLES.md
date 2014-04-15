Configuring an IPMI BMC
=======================


```puppet
  include bmclib
  bmc { 'ipmidevice':
    ensure   => 'present,
    vlanid   => '1',
    ip       => '192.168.1.22',
    netmask  => '255.255.255.0',
    gateway  => '192.168.1.1',
  }
  bmcuser { 'bmcuser':
    ensure    => 'presetn',
    privlevel => 'admin'
    username  => 'username',
    userpass  => 'userpass',
    force     => true,
    require   => Class['bmclib']
  }
```
