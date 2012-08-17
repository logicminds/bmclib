Puppet::Type.type(:bmc).provider(:freeipmi) do
    desc "Provides Freeipmi support for the bmc type"
    
    commands :ipmitool
    
    
    def create
        ipmitool "lan set #{resource[:channel} ipsrc", resource[:ipsource]
        if resource[:ipsource] == "static"
          ipmitool "lan set 1 ipaddr", resource[:ip]
          ipmitool "lan set 1 netmask", resource[:subnet]
          ipmitool "lan set 1 defgw", resource[:gateway]
          ipmitool "lan set 1 snmp", resource[:snmp]
        end
        if resource[:vlanid]
          ipmitool "lan set 1 vlan id", resource[:vlanid]
        end
        if resource[:bootdev]
          ipmitool "chassis bootdev", resource[:bootdev]
        end
        if resource[:user1] and resource[:user1pass]

        end



    end

def destroy

end

def getuserlist
  # get the user list and parse the results
end

def checkuser

end

def exists?
  @laninfo = ipmitool "lan print 1"


end

    def parse(landata)

      multikey = ""
      multivalue = {}

      landata.lines.each do |line|
        # clean up the data from spaces
        item = line.split(':', 2)
        key = item.first.strip.downcase
        value = item.last.strip
        @laninfo[key] = value

      end
      return @laninfo
    end


# Display/reset password for default root user (userid '2')
ipmitool user list 1
ipmitool user set password 2 <new_password>

# Display/configure lan settings
ipmitool lan print 1


end