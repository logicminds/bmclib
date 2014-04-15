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

  mk_resource_methods

  def create
    user = resource[:username]
    id = find_user_id(resource[:username])

    ipmitoolcmd([ "user", "set", "name", id, resource[:username]] )
    if resource[:userpass]
      ipmitoolcmd([ "user", "set", "password", id, resource[:userpass] ])
    end
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

  def find_user_id(username)
    userlist.each do | user, hash |
      if username == hash[:name]
        return hash[:id]
      elsif hash[:username] =~ /\(Empty User\)/
        return hash[:id]
      end
    end
    # If we got here, we must be adding a new user
    available_ids = (2..10).to_a
    userlist.each do | user, hash |
      if hash[:name]
        available_ids.delete(hash[:id])
      end
    end
    return available_ids.first
  end

  def userlist()
    @cached_userlist ||= self.class.userlist()
    return @cached_userlist
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
      user[:id] = data.first.strip.to_i
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
           :id => hash[:id],
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
      if provider = users.find{|user| user.name == name }
        resources[name].provider = provider
      end
    end
  end

end
