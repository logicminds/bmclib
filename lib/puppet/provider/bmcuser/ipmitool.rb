Puppet::Type.type(:bmc).provider(:freeipmi) do
    desc "Provides Freeipmi support for the bmc type"

    commands :ipmitool
    @users = {}

    def create
      userid = getuserid(params[:username])
      ipmitool user enable 3
      ipmitool user set name 3 admin3
      ipmitool user set password 3 password
      ipmitool user priv resource[:userid] 4 2


    #  1 Callback level
    #  2 User level
    #  3 Operator level
    #  4 Administrator level
    #  5 OEM Proprietary level
    end

    def destroy

    end

    def exists?
       if userexists?(resource[:username])
         value = userlist[:username][:enabled]
         value = value & userlist[:username][:priv].downcase! == resource[:privlevel].downcase!

       else
          return false
       end

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

    def getuserid(user)
      return userlist[user][:id]
    end

    def userlist
      if @users.length < 1
        userdata = ipmitool "user list 1"
        @users = parse(userdata)
      end
      return @users
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

end