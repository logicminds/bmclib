include bmclib
bmc { 'ipmidevice':
  ensure   => enabled,
  provider => 'ipmitool',
  vlanid   => '1',
  ip       => '192.168.1.22',
  netmask  => '255.255.255.0',
  gateway  => '192.168.1.1',
  snmp     => 'public',
  force    => true,
  require  => Class['bmclib'],
}

bmcuser { 'bmcuser':
  ensure    => enabled,
  provider  => 'freeipmi',
  privlevel => 'admin',
  username  => 'username',
  userpass  => 'userpass',
  force     => true,
  require  => Class['bmclib'],
}
