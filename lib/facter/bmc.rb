#bmc.rb

Facter.add("bmc_ip", :timeout => 2) do
  confine :is_virtual => [:false, false]
  setcode do
    ip
  end
end

Facter.add("bmc_mac", :timeout => 2) do
  confine :is_virtual => [:false, false]
  setcode do
    mac
  end
end

Facter.add("bmc_subnet", :timeout => 2) do
  confine :is_virtual => [:false, false]
  setcode do
    subnet
  end
end

Facter.add("bmc_gateway", :timeout => 2) do
  confine :is_virtual => [:false, false]
  setcode do
    gateway
  end
end

def lanconfig
  @lanconfig ||= parse_laninfo_ipmitool || parse_laninfo_freeipmi || {}
end

def parse_laninfo_ipmitool
  if ! ipmitool
    return
  end
  channel_lookup = {
    'Intel Corporation' => 3,
    'HP' => 2,
  }
  channel = channel_lookup.fetch(Facter.value(:manufacturer), 1)
  landata = Facter::Core::Execution.exec("#{ipmitool} lan print #{channel} 2>/dev/null")
  laninfo = {}

  landata.lines.each do |line|
    # clean up the data from spaces
    item = line.split(':', 2)
    key = item.first.strip.downcase.gsub(' ','_')
    value = item.last.strip
    laninfo[key] = value
  end
  return laninfo
end

def parse_laninfo_freeipmi
  if ! bmc_config
    return
  end
  output = Facter::Util::Resolution.exec("bmc-config --checkout --section Lan_Conf --disable-auto-probe --verbose").lines.find_all { |l| l =~ /^\s+[^#]/}
  if ! output.empty?
    Hash[output.map { |e| e.downcase.split }]
  end
end

def ipmitool
  Facter::Util::Resolution.which('ipmitool')
end

def bmc_config
  Facter::Util::Resolution.which('bmc-config')
end

def ip
  lanconfig["ip_address"]
end

def mac
  lanconfig["mac_address"]
end

def subnet
  lanconfig["subnet_mask"]
end

def gateway
  lanconfig["default_gateway_ip"] || lanconfig["default_gateway_ip_address"]
end

def vlanid
  lanconfig["802.1q_vlan_id"] || lanconfig["vlan_id"]
end

def dhcp?
  lanconfig["ip_address_source"].match(/dhcp$/i) != nil
end

def static?
  lanconfig["ip_address_source"].match(/static/i) != nil
end

def ipsrc
  lanconfig["ip_address_source"].downcase!
end
