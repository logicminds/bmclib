#bmc.rb

Facter.add("bmc_ip") do
  confine :is_virtual => :false
  setcode do
    ip
  end
end

Facter.add("bmc_mac") do
  confine :is_virtual => :false
  setcode do
    mac
  end
end

Facter.add("bmc_subnet") do
  confine :is_virtual => :false
  setcode do
   subnet
  end
end

Facter.add("bmc_gateway") do
  confine :is_virtual => :false
  setcode do
   gateway
  end
end


 def lanconfig
    @lanconfig ||= parse_laninfo
  end

  def parse_laninfo
    if ipmitool.empty?
      return {}
    end
    landata = `#{ipmitool} lan print 1 2>/dev/null`
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

  def ipmitool
    @ipmitool ||= `which ipmitool 2>/dev/null`.chomp
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



