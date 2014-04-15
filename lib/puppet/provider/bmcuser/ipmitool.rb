Puppet::Type.type(:bmcuser).provide(:ipmitool) do
  desc "Provides ipmitool support for the bmc type"

  commands :ipmitoolcmd => 'ipmitool'
  confine :is_virtual => "false"
  # if the open ipmi driver does not exist we can perform any of these configurations
  #      # check to see that openipmi driver is loaded and ipmi device exists
  confine :true => File.exists?('/dev/ipmi0') || File.exists?('/dev/ipmi/0') || File.exists?('/dev/ipmidev/0')

  self::CHANNEL = 1
  self::PRIV = {
      :administrator => 4,
      :user => 2,
      :callback => 1,
      :operator => 3,
      :noaccess => 15
  }

  def create
    user = resource[:username]
    id = newuserid
    ipmitoolcmd([ "user", "set", "name", id, user] )
    ipmitoolcmd([ "user", "set", "password", id, resource[:password] ])
    ipmitoolcmd([ "user", "priv", id, self.class::PRIV[resource[:privlevel]], self.class::CHANNEL ])
    ipmitoolcmd([ "user", "enable", id ])
  end

  def destroy
    ipmitoolcmd([ "user", "set", "name", id, user ])
    ipmitoolcmd([ "user", "priv", id, self.class::PRIV[:noaccess], self.class::CHANNEL ])
    ipmitoolcmd([ "user", "disable", id ])
  end

  def privequal?(user)
    self.class::PRIV[@property_hash[:privlevel]]
  end

  def exists?
     @property_hash[:ensure] == :present
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

  def username()
    @property_hash[:username]
  end

  def userpass()
    @property_hash[:userpass]
  end

  def userlist()
    @cached_userlist ||= self.userlist()
  end

  def privlevel()
    @property_hash[:privlevel]
  end

  def self.userlist
    return parse ipmitoolcmd([ "user", "list", "1" ])
  end

  def self.parse(userdata)
    userlist = {}
    userdata.lines.each do | line |
      user = {}
      # skip the header
      next if line.match(/^ID/)
      data = line.split()
      user[:id] = data.first.strip
      user[:name] = data[1].strip
      user[:callin] = data[2].strip == "true"
      user[:linkauth] = data[3].strip == "true"
      user[:enabled] = data[4].strip == "true"
      user[:priv] = data[5].strip.downcase
      userlist[user[:name]] = user
    end
    return userlist
  end

  def self.instances
    bmcuser_instances = []
    userlist.each do | user, hash |
      # create the resource
      bmcuser_instances << new(
           :name => user,
           :username => user,
           :ensure => :present,
           :privlevel => hash[:priv],
           :enabled => hash[:enabled],
           :userpass => '*************',
           :provider => 'ipmitool'
      )
    end
    bmcuser_instances
  end

  def self.prefetch(resources)
    users = instances
    resources.keys.each do | name |
      if provider = users.find{|user| user[:name] == name }
        resources[:name][:provider] = provider
      end
    end
  end

end
