#bmc.rb
Facter.add("bmc_ip", :timeout => 2) do
  confine :bmc_device_present => [:true, true]
  confine :bmc_tools_present => [:true, true]
  setcode do
    ip
  end
end

Facter.add("bmc_mac", :timeout => 2) do
  confine :bmc_device_present => [:true, true]
  confine :bmc_tools_present => [:true, true]
  setcode do
    mac
  end
end

Facter.add("bmc_subnet", :timeout => 2) do
  confine :bmc_device_present => [:true, true]
  confine :bmc_tools_present => [:true, true]
  setcode do
    subnet
  end
end

Facter.add("bmc_gateway", :timeout => 2) do
  confine :bmc_device_present => [:true, true]
  confine :bmc_tools_present => [:true, true]
  setcode do
    gateway
  end
end

Facter.add("bmc_ipmi_version") do
  confine :bmc_device_present => [:true, true]
  confine :bmc_tools_present => [:true, true]
  setcode do
    ipmi_version
  end
end

Facter.add("bmc_firmware_revision") do
  confine :bmc_device_present => [:true, true]
  confine :bmc_tools_present => [:true, true]
  setcode do
    firmware_revision
  end
end


def lanconfig
  @lanconfig ||= parse_laninfo
end

def mcconfig
  @mcconfig ||= parse_mcinfo
end

def parse_laninfo
  if ipmitool.empty? or ipmitool.nil?
    return {}
  end
  channel_lookup = {
    'Dell Inc.'         => 1,
    'FUJITSU'           => 2,
    'FUJITSU SIEMENS'   => 2,
    'HP'                => 2,
    'Intel Corporation' => 3,
  }
  channel = channel_lookup.fetch(Facter.value(:manufacturer), 1)
  landata = Facter::Core::Execution.exec("#{ipmitool} lan print #{channel} 2>/dev/null") || ''
  laninfo = {}
  landata.lines.each do |line|
    # clean up the data from spaces
    item = line.split(':', 2)
    key = item.first.strip.downcase.gsub(' ','_')
    value = item.last.strip
    laninfo[key] = value
  end
  laninfo
end

def parse_mcinfo
  if ipmitool.empty? or ipmitool.nil?
    return {}
  end
  mcdata = Facter::Core::Execution.exec("#{ipmitool} mc info 2>/dev/null") || ''
  mcinfo = {}
  mcdata.lines.each do |line|
    # clean up the data from spaces
    item = line.split(':', 2)
    key = item.first.strip.downcase.gsub(' ','_')
    value = item.last.strip
    mcinfo[key] = value
  end
  mcinfo
end

def ipmitool
  unless @ipmitool
    timeout = Facter::Core::Execution.which('timeout')
    ipmitool_cmd = Facter::Core::Execution.which('ipmitool')
    if ipmitool_cmd and timeout
      @ipmitool = "#{timeout} 2 #{ipmitool_cmd}"
    elsif ipmitool_cmd
      @ipmitool = ipmitool_cmd
    else
      @ipmitool = nil
    end
  end
  @ipmitool
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
  lanconfig["default_gateway_ip"]
end

def vlanid
  lanconfig["802.1q_vlan_id"]
end

def dhcp?
  lanconfig["ip_address_source"].match(/dhcp/i) != nil
end

def static?
  lanconfig["ip_address_source"].match(/static/i) != nil
end

def ipsrc
  lanconfig["ip_address_source"].downcase!
end

def firmware_revision
  mcconfig["firmware_revision"]
end

def ipmi_version
  mcconfig["ipmi_version"]
end
