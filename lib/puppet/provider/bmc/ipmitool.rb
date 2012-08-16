Puppet::Type.type(:bmc).provider(:freeipmi) do
    desc "Provides Freeipmi support for the bmc type"
    
    commands :ipmitool
    
    
    def create
        ipmitool "lan set #{resource[:channel} ipsrc", resource[:ipsource]
        ipmitool "lan set #{resource[:channel} ipaddr", resource[:ip]
        ipmitool "lan set #{resource[:channel} netmask", resource[:subnet]
        ipmitool "lan set #{resource[:channel} defgw ipaddr", resource[:gateway]
    end

def destroy
    
end

def exists?
    
    
end


# Display/reset password for default root user (userid '2')
ipmitool user list 1
ipmitool user set password 2 <new_password>

# Display/configure lan settings
ipmitool lan print 1


end