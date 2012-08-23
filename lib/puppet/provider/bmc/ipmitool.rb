Puppet::Type.type(:bmc).provider(:ipmitool) do
  desc "Provides Freeipmi support for the bmc type"

  command :ipmitool
  #confine :is_virtual => "false"

  def create
    if resource[:ipsource] == "static"
      ip = resource[:ip]
      netmask = resource[:netmask]
      gateway = resource[:gateway]
    end
    if resource[:snmp]
        snmp = resource[:snmp]
    end
    ipsrc = resource[:ipsource]
    if resource[:vlanid]
      vlanid = resource[:vlanid]
    end
    enable_channel

  end

  def enable_channel
     ipmitool 'lan set 1 access on'
  end

  def disable_channel
    ipmitool 'lan set 1 access off'
  end

  def destroy
    ipsrc = "dhcp"
    disable_channel
  end

  def exists?
     if resource[:force]
       return false
     end
     # since snmp and vlan information won't be available everytime, we can't reapply the config everytime
     value = ip.eql?(resource[:ip]) & netmask.eql?(resource[:netmask]) & gateway.eql?(resource[:gateway])
  end

  def lanconfig
    @lanconfig ||= parse_laninfo
  end

  def parse_laninfo
    landata = ipmitool 'lan print 1'
    laninfo = {}

    landata.lines.each do |line|
      # clean up the data from spaces
      item = line.split(':', 2)
      key = item.first.strip.downcase
      value = item.last.strip
      laninfo[key] = value
    end
    return laninfo
  end

  def ip
    lanconfig["ip address"]
  end

  def mac
    lanconfig["mac address"]
  end

  def subnet
    lanconfig["subnet mask"]
  end

  def gateway
    lanconfig["default gateway ip"]
  end

  def vlanid
    lanconfig["802.1q vlan id"]
  end

  def dhcp?
    lanconfig["ip address source"].match(/dhcp/i) != nil
  end

  def static?
    lanconfig["ip address source"].match(/static/i) != nil
  end

  def ipsrc
    lanconfig["ip address source"].downcase!
  end

  def ipsrc=(source)
    ipmitool 'lan set 1 ipsrc', source
  end

  def snmp=(community)
    ipmitool 'lan set 1 snmp', community
  end

  def ip=(address)
    ipmitool 'lan set 1 ipaddr', address
  end

  def subnet(subnet)
    ipmitool 'lan set 1 netmask', subnet
  end

  def gateway=(address)
    ipmitool 'lan set 1 defgw ipaddr', address
  end

  def vlanid=(vid)
     ipmitool 'lan set 1 vlan id', vid
  end

end