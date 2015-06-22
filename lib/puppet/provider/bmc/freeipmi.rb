Puppet::Type.type(:bmc).provide(:freeipmi) do
  desc "Provides freeipmi support for the bmc type"

  commands :ipmicmd => 'bmc-config'
  commands :sh => 'sh'
  defaultfor :osfamily => :redhat

  confine :is_virtual => "false"
  # if the open ipmi driver does not exist we can perform any of these configurations
  #      # check to see that openipmi driver is loaded and ipmi device exists
  confine :true => File.exists?('/dev/ipmi0') || File.exists?('/dev/ipmi/0') || File.exists?('/dev/ipmidev/0')

  ##### These are the default ensurable methods that must be implemented
  def install
    if resource[:ipsource] == "Static"
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


  # return all instances of this resource which really should only be one instance
  def self.instances
    info       = self.laninfo
    name       = info["MAC_Address"]
    ipsource   = info["IP_Address_Source"].downcase!
    ip         = info["IP_Address"]
    netmask    = info["Subnet_Mask"]
    gateway    = info["Default_Gateway_IP_Address"]
    vlanid     = info["Vlan_id"]
    lan_channel_access_mode = info["Volatile_Access_Mode"]

    new(:name => name, :ensure => :present,
        :ipsource => ipsource, :ip => ip,
        :netmask => netmask, :gateway => gateway,
        :vlanid => vlanid )
  end

  # bmc puppet parameters to get / set
  # if your making a new provider implement all of these
  def ipsource
    lanconfig["ip address source"].downcase!
  end

  def ipsource=(source)
    ipmicmd([ "--commit", "--key-pair", "Lan_Conf:IP_Address_Source=#{source}" ])
  end

  def ip
    lanconfig["IP_Address_Source"]
  end

  def ip=(address)
    ipmicmd([ "--commit", "--key-pair", "Lan_Conf:IP_Address=#{address}" ])
  end

  def netmask
    lanconfig["Subnet_Mask"]
  end

  def netmask=(subnet)
    ipmicmd([ "--commit", "--key-pair", "Lan_Conf:Subnet_Mask=#{subnet}" ])
  end

  def gateway
    lanconfig["Default_Gateway_IP_Address"]
  end

  def gateway=(address)
    ipmicmd([ "--commit", "--key-pair", "Lan_Conf:Default_Gateway_IP_Address=#{address}" ])
  end

  def vlanid
    lanconfig["Vlan_id"]
  end

  def vlanid=(vid)
    ipmicmd([ "--commit", "--key-pair", "Lan_Conf:Vlan_id=#{vid}" ])
  end

  #def snmp
  #  # TODO implement how to get the snmp string even when the device doesn't support snmp lookups
  #end
  #
  #def snmp=(community)
  #  ipmicmd 'lan set 1 snmp', community
  #end

  # end - bmc parameters


  def self.laninfo
    # `bmc-config --section Lan_Conf --verbose` can return a non-zero RC so we have to wrap this
    landata = sh([ "-c", "(bmc-config --verbose --checkout --section Lan_Conf --section Lan_Channel --disable-auto-probe --verbose || :)" ])
    output = landata.lines.find_all { |l| l =~ /^\s+[^#]/}
    if ! output.empty?
      info = Hash[output.map { |e| e.split }]
    end
    return info
  end

  private

  def mac
    lanconfig["MAC_Address"]
  end

  def dhcp?
    lanconfig["IP_Address_Source"].match(/^Use_DHCP$/) != nil
  end

  def static?
    lanconfig["IP_Address_Source"].match(/^Static$/) != nil
  end

  def channel_enabled?
    lanconfig["Volatile_Access_Mode"].match(/^(Pre_Boot_Only|Always_Available|Shared)$/) != nil
  end

  def enable_channel
    if ! channel_enabled?
      puts "enabling"
      ipmicmd([ "--commit", "--key-pair", "Lan_Channel:Volatile_Access_Mode=Always_Available" ])
    end
  end

  def disable_channel
    if channel_enabled?
      ipmicmd([ "--commit", "--key-pair", "Lan_Channel:Volatile_Access_Mode=Disabled" ])
    end
  end

  def lanconfig
    @lanconfig ||= self.class.laninfo
  end



end
