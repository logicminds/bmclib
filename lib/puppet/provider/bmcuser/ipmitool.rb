Puppet::Type.type(:bmc).provide(:ipmitool) do
    desc "Provides Freeipmi support for the bmc type"

    #confine :is_virtual => "false"
    command :ipmitool
    confine :is_virtual => "false"
    # if the open ipmi driver does not exist we can perform any of these configurations
    #      # check to see that openipmi driver is loaded and ipmi device exists
    confine :true => File.exists?('/dev/ipmi0') || File.exists?('/dev/ipmi/0') || File.exists?('/dev/ipmidev/0')

    @users = {}
    @channel = 1
    @priv = {
        :admin => 4,
        :user => 2,
        :callback => 1,
        :operator => 3,
        :noaccess => 15,
    }
    def create

      user = resources[:username]
      id = userid(user)
      if not userexists?(user)
        ipmitool "user set name", id, user
        ipmitool "user set password", id, resource[:password]
        ipmitool "user priv", id, @priv[resource[:privlevel]], @channel
        ipmitool "user enable", id

      else
        if not isenabled?(user)
          ipmitool "user enable", id
        end
        if not privequal?(user)
          ipmitool "user priv", id, @priv[resource[:privlevel]], @channel
        end
        if resource[:force]
          ipmitool "user set password", id, resource[:password]
        end

      end

    end

    def destroy
      ipmitool "user set name", id, user
      ipmitool "user priv", id, @priv[:noaccess], @channel
      ipmitool "user disable", id
    end

    def privequal?(user)
      privlevel?(user) == @priv[resource[:privlevel]]

    end

    def exists?
       if userexists?(resource[:username])
         value = userlist[:username][:enabled]
         value = value & privequal?(resource[:username]) & ! resource[:force]
       else
          return false
       end
      return value
    end

    def newuserid
      userlist.each do | user |
        if user[:name] =~ /\(Empty User\)/
          return user[:id]
        end
      end
      # If we get here all the users are currently occupied, lets check for disabled users
      userlist.each do | user |
        if ! user[:enabled]
          return user[:id]
        end
      end
    end

    def isenabled?(user)
      return userlist[user][:enabled]
    end

    def userid(user)
      if userlist[user][:id]
        return userlist[user][:id]
      else
        return newuserid
      end
    end

    def userlist
      if @users.length < 1
        userdata = ipmitool "user list 1"
        @users = parse(userdata)
      end
      return @users
    end

    def privlevel?(user)
      return userlist[user][:priv].downcase
    end

    def userexists?(user)
      return ! userlist[user].nil?
    end

    def parse(userdata)
      userlist = {}
      userdata.lines.each do | line|
        user = {}
        # skip the header
        next if line.match(/^ID/)
        data = line.split(/\t/)
        user[:id] = data.first.strip
        user[:name] = data[1].strip
        user[:callin] = data[2].strip == "true"
        user[:linkauth] = data[3].strip == "true"
        user[:enabled] = data[4].strip == "true"
        user[:priv] = data[5].strip
        userlist[user[:name]] = user

      end
      return userlist

    end

    def self.instances
      userdata = ipmitool "user list 1"
      userdata.lines.each do | line|
        user = {}
        # skip the header
        next if line.match(/^ID/)
        data = line.split(/\t/)
        user[:id] = data.first.strip
        user[:name] = data[1].strip
        user[:callin] = data[2].strip == "true"
        user[:linkauth] = data[3].strip == "true"
        user[:enabled] = data[4].strip == "true"
        user[:priv] = data[5].strip

        # create the resource
        new(:name => user[:name], :ensure => :present,
            :privlevel => user[:priv], :userpass => '*************' )
      end

    end

    def self.prefetch(resources)
      users = instances
      resources.keys.each do | name|
        if provider = users.find{|user| user.name == name }
          resources[name].provider = provider
        end
      end
    end

end