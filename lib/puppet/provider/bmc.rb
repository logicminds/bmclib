class Puppet::Provider::Bmc < Puppet::Provider
  confine :is_virtual => "false"
  # if the open ipmi driver does not exist we can perform any of these configurations
  #      # check to see that openipmi driver is loaded and ipmi device exists
  confine :true => File.exists?('/dev/ipmi0') || File.exists?('/dev/ipmi/0') || File.exists?('/dev/ipmidev/0')

  ##### These are the default ensurable methods that must be implemented
  def install
    if resource[:ipsource] == "static"
      ip = resource[:ip]
      netmask = resource[:netmask]
      gateway = resource[:gateway]
    end

    ipsrc = resource[:ipsource]
    if resource[:vlanid]
      vlanid = resource[:vlanid]
    end
    enable_channel
  end

  def remove
    ipsrc = "dhcp"
    disable_channel
  end

  def exists?
    # since snmp and vlan information won't be available everytime, so we can't reapply the config everytime
    begin
      value = ip.eql?(resource[:ip]) & netmask.eql?(resource[:netmask]) & gateway.eql?(resource[:gateway])
    rescue
      false
    end
  end

  ##### END -- These are the default ensurable methods that must be implemented
end
