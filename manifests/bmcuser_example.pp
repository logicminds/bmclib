class bmclib::bmcuser_example{
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