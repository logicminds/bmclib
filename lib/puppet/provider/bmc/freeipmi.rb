begin
    require 'rubyipmi'
rescue
    Puppet.warning "You need the gem rubyipmi installed to use this bmc type."
end

Puppet::Type.type(:bmc).provider(:freeipmi) do
    desc "Provides Freeipmi support for the bmc type"
    
    commands :ipmitool
    
    def create
    
    end

    def destroy
        
    end

    def exists?
        
        
    end

    def host
       @host = Rubyipmi.connect(" ")
    end
# Display/reset password for default root user (userid '2')
ipmitool user list 1
ipmitool user set password 2 <new_password>

# Display/configure lan settings
ipmitool lan print 1
ipmitool lan set 1 ipsrc [ static | dhcp ]
ipmitool lan set 1 ipaddr 192.168.1.101
ipmitool lan set 1 netmask 255.255.255.0
ipmitool lan set 1 defgw ipaddr 192.168.1.254


end