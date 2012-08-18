Puppet::Type.newtype(:bmc) do
  @doc = "Manage BMC devices"
    

  ensurable


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
                   if not File.exists?('/dev/hpilo/dXccbN')
                     raise ArgumentError , "The hp ilo driver cannot be found, is the ilo driver installed and loaded?"
                   end
               else
                    raise ArgumentError , "The manufacturer \"#{$manufacturer}\" is currently not
                              supported under the oem provider, please try freeipmi or ipmitool"
            end

                
        end
    end
        
    
    
    newparam(:ipsource) do
        desc "The type of ip address to use static or dhcp"
        newvalues(:static, :dhcp)
        defaultto{:dhcp}

    end

        newparam(:snmp) do
          desc "The snmp community string for the bmc device"


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
    
    newparam(:netmask) do
        desc "The netmask address of the bmc device"
        validate do |value|
            unless validaddr?(value)
                raise ArgumentError , "%s is not a valid netmask" % value
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
    

    newparam(:vlanid) do
      defaultto {"off"}
        validate do |value|
            unless (1..4094).include?(value.to_i) or value == "off"
                raise ArgumentError , "%s is not a valid vlan id, must be 1-4094" % value
            end
        end
    end

    
    
    
    
    

end


