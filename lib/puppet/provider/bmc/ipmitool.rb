Puppet::Type.type(:bmc).provide(:ipmitool) do
  desc "Provides ipmitool support for the bmc type"

  commands :ipmitoolcmd => 'ipmitool'
  # if the open ipmi driver does not exist we can perform any of these configurations
  # check to see that openipmi driver is loaded and ipmi device exists
  confine :bmc_device_present => [:true, true]
  confine :is_virtual => "false"

  CHANNEL_LOOKUP = {
      'Dell Inc.'         => '1',
      'FUJITSU'           => '2',
      'FUJITSU SIEMENS'   => '2',
      'HP'                => '2',
      'Intel Corporation' => '3',
  }

  ##### These are the default ensurable methods that must be implemented
  def install
    if resource[:ipsource] == :static
      ip = resource[:ip]
      netmask = resource[:netmask]
      gateway = resource[:gateway]
    end

    ipsrc = resource[:ipsource]
    if resource[:vlanid]
      vlanid = resource[:vlanid]
    end
    #enable_channel  # TODO is this needed? what does this do ?
  end

  def remove
    ipsrc = "dhcp"
    #disable_channel  #TODO is this needed?
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


  # return all instances of this resource which really should only be one instance
  def self.instances
    info       = self.laninfo
    name       = info["mac address"]
    ipsource   = info["ip address source"].downcase!.to_sym
    ip         = info["ip address"]
    netmask    = info["subnet mask"]
    gateway    = info["default gateway ip"]
    vlanid     = info["802.1q vlan id"]

    new(:name => name, :ensure => :present,
        :ipsource => ipsource, :ip => ip,
        :netmask => netmask, :gateway => gateway,
        :vlanid => vlanid )
  end

  def self.prefetch(resources)
    devices = instances
    unless devices
      resources.keys.each do | name|
        if provider = devices.find{|device| device.name == name }
          resources[name].provider = provider
        end
      end
    end
  end

  # bmc puppet parameters to get / set
  # if your making a new provider implement all of these
  def ipsource
    lanconfig["ip address source"].downcase!
  end

  def ipsource=(source)
    ipmitoolcmd([ "lan", "set", channel, "ipsrc", source ])
  end

  def ip
    lanconfig["ip address"]
  end

  def ip=(address)
    ipmitoolcmd([ "lan", "set", channel, "ipaddr", address ])
  end

  def netmask
    lanconfig["subnet mask"]
  end

  def netmask=(subnet)
    ipmitoolcmd([ "lan", "set", channel, "netmask", subnet ])
  end

  def gateway
    lanconfig["default gateway ip"]
  end

  def gateway=(address)
    ipmitoolcmd([ "lan", "set", channel, "defgw", "ipaddr", address ])
  end

  def vlanid
    lanconfig["802.1q vlan id"]
  end

  def vlanid=(vid)
    ipmitoolcmd([ "lan", "set", channel, "vlan", "id", vid ])
  end

  #def snmp
  #  # TODO implement how to get the snmp string even when the device doesn't support snmp lookups
  #end
  #
  #def snmp=(community)
  #  ipmitoolcmd 'lan set 1 snmp', community
  #end

  # end - bmc parameters


  def self.laninfo
    landata = ipmitoolcmd([ "lan", "print", CHANNEL_LOOKUP.fetch(Facter.value(:manufacturer), '1') ])
    info = {}
    landata.lines.each do |line|
      # clean up the data from spaces
      item = line.split(':', 2)
      key = item.first.strip.downcase
      value = item.last.strip
      info[key] = value
    end
    info
  end

  private

  def mac
    lanconfig["mac address"]
  end

  def dhcp?
    lanconfig["ip address source"].match(/dhcp/i) != nil
  end

  def static?
    lanconfig["ip address source"].match(/static/i) != nil
  end

  def channel_enabled?
    # TODO implement how to look up this info
    true
  end

  def channel
    CHANNEL_LOOKUP.fetch(Facter.value(:manufacturer), '1')
  end

  def enable_channel
    ipmitoolcmd([ "lan", "set", channel, "access", "on" ])
  end

  def disable_channel
    ipmitoolcmd([ "lan", "set", channel, "access", "off" ])
  end

  def lanconfig
    @lanconfig ||= self.class.laninfo
  end



end
