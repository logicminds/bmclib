Puppet::Type.newtype(:bmcuser) do
  @doc = "Manage BMC devices"


  ensurable

    newparam(:username) do
        desc "The username to be added"

    end

    newparam(:userpass) do
        desc "The password of the user to create"

    end

    newparam(:force) do
          desc "The force parameter will set the password of the user with every puppet run"
          newvalues(true, false)
    end

    newparam(:privlevel) do
          desc "The public certificate of the user"
          newvalues(:admin, :user, :operator, :callback)
      end

  newparam(:provider) do
     desc "The type of ipmi provider to use when setting up the bmc"
     newvalues(:ipmitool)

     defaultto do

       provider = resource[:provider].downcase
       if provider =~ /freeipmi|impitool/
         # check to see that openipmi driver is loaded and ipmi device exists
         opendriver = File.exists?('/dev/ipmi0') || File.exists?('/dev/ipmi/0') || File.exists?('/dev/ipmidev/0')
         if not opendriver
           raise ArgumentError , "The openipmi driver cannot be found, is openipmi installed and loaded correctly?"
         end
         return :ipmitool
       elsif provider == "oem"
         case $manufacturer.downcase!
           when "hp", "hewlett packard"
           # check if hp's ilo driver is installed
           if not File.exists?('/dev/hpilo/dXccbN')
             raise ArgumentError , "The hp ilo driver cannot be found, is the ilo driver installed and loaded?"
           else
             return :hp
           end
           else
           raise ArgumentError , "The manufacturer \"#{$manufacturer}\" is currently not
                                              supported under the oem provider, please try freeipmi or ipmitool"
         end

       end
     end
   end

end