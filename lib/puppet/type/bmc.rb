Puppet::Type.newtype(:bmc) do
    

  @doc = "Manage BMC devices"
    
    #feature :installable, "The provider can install packages.",
    #:methods => [:install]
  ensurable

    newparam(:user1) do
        desc "The username to be added"
        
    end
    
    newparam(:user1pass) do
        desc "The password of the user1 to create"
        
        
    end
    
    
    newparam(:provider) do
        desc "The type of ipmi provider to use when setting up the bmc"
        if $is_virtual
            raise ArgumentError , "Virtual machines do not have an ipmi device, please do not try to assign use the bmc type with virtual machines" 
        end
        resource[:provider] = "ipmitool" if provider.nil?
        provider = resource[:provider].downcase
        if not ["freeipmi", "ipmitool", "hp", "oem"].include?(provider)
            raise ArgumentError , "#{provider} is an invalid bmc provider"
        end
        
        newvalues(:freeipmi, :ipmitool, :hp, :oem)
        # Autodetect the provider unless specified
        provider = resource[:provider].downcase
        if provider =~ /freeipmi|impitool/
            # check to see that openipmi driver is loaded and ipmi devic exists
            opendriver = File.exists?('/dev/ipmi0') || File.exists?('/dev/ipmi/0') || File.exists?('/dev/ipmidev/0')
            if not opendriver
                raise ArgumentError , "The openipmi driver cannot be found, is openipmi installed and loaded correctly?"

            end
        elsif provider == "oem"
            case $manufacturer.downcase! do
               when "hp", "hewlett packard"
                    resource[:provider] = "hp"
                # check if hp's ilo driver is installed
               else
                    raise ArgumentError , "The manufacturer \"#{$manufacturer}\" is currently not supported under the oem provider, please try freeipmi or ipmitool"
            end

                
        end
    end
        
    
    
    newparam(:ipsource) do
        desc "The type of ip address to use static or dhcp"
        newvalues(:static, :dhcp)
        
    end
    
    
    newparam(:ip) do
        desc "The ip address of the bmc device"
        validate do |value|
            unless validaddr?(value)
                raise ArgumentError , "%s is not a valid ip" % value
            end
        end
    end

            
    # This is just a simple verification to valid ip related sources
    def validaddr?(source)
            valid = /^([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])(\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])){3}$/.match("#{source}")
            ! valid.nil?
     
    end
    
    newparam(:bootdevice) do
        # freeipmi actually support more boot devices but these are the basic devices
        desc "The boot device that should be set for next reboot"
        newvalues(:pxe, :floppy, :disk, :bios, :cdrom)
    end
    
    newparam(:subnet) do
        desc "The subnet address of the bmc device"
        validate do |value|
            unless validaddr?(value)
                raise ArgumentError , "%s is not a valid subnet" % value
            end
        end
    end
    
    newparam(:gateway) do
        desc "The gateway address of the bmc device"
        validate do |value|
            unless validaddr?(value)
                raise ArgumentError , "%s is not a valid gateway" % value
            end
        end
    end
    
    newparam(:channel) do
        desc "The lan channel to use to configure the bmc device"
        # "1 == local ipmi driver"
        # "2 == lan support (requires credentials and IP)"
        validate do |value|
            unless (1..2).include?(value.to_i)
                # default channel to use
                resource[:channel] = 1
            end
        end
    end
    
    newparam(:vlanid) do
        validate do |value|
            unless (1..4094).include?(value.to_i)
                raise ArgumentError , "%s is not a valid vlan id, must be 1-4094" % value
            end
        end
    end

    
    
    
    
    

end


