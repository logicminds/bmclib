Puppet::Type.type(:bmcuser).provide(:ipmitool) do
  desc "Provides ipmitool support for the bmc type"

  commands :ipmitoolcmd => 'ipmitool'
  confine :bmc_device_present => [:true, true]
  confine :is_virtual => "false"
  # if the open ipmi driver does not exist we can perform any of these configurations
  #      # check to see that openipmi driver is loaded and ipmi device exists
  confine :true => File.exists?('/dev/ipmi0') || File.exists?('/dev/ipmi/0') || File.exists?('/dev/ipmidev/0')

  CHANNEL_LOOKUP = {
      'Dell Inc.'         => '1',
      'FUJITSU'           => '2',
      'FUJITSU SIEMENS'   => '2',
      'HP'                => '2',
      'Intel Corporation' => '3',
  }

  @users = {}
  @priv = {
    :administrator => 4,
    :admin => 4,
    :user => 2,
    :callback => 1,
    :operator => 3,
    :noaccess => 15,
  }
  def create

    user = resource[:username]
    id = userid(user)
    if not userexists?(user)
      ipmitoolcmd([ "user", "set", "name", id, user] )
      ipmitoolcmd([ "user", "set", "password", id, resource[:password] ])
      ipmitoolcmd([ "user", "priv", id, @priv[resource[:privlevel]], channel ])
      ipmitoolcmd([ "user", "enable", id ])

    else
      if not isenabled?(user)
        ipmitoolcmd([ "user", "enable", id ])
      end
      if not privequal?(user)
        ipmitoolcmd([ "user", "priv", id, @priv[resource[:privlevel]], channel ])
      end
      if resource[:force]
        ipmitoolcmd([ "user", "set", "password", id, resource[:password] ])
      end

    end

  end

  def destroy
    ipmitoolcmd([ "user", "set", "name", id, user ])
    ipmitoolcmd([ "user", "priv", id, @priv[:noaccess], channel ])
    ipmitoolcmd([ "user", "disable", id ])
  end

  def privequal?(user)
    privlevel?(user) == @priv[resource[:privlevel]]

  end

  def exists?
    if userexists?(resource[:username])
      value = userlist[:username][:enabled]
      value = value & privequal?(resource[:username]) & ! resource[:force]
    else
      value = false
    end
    value
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
      userlist[user][:id]
    else
      newuserid
    end
  end

  def userlist
    if @users.length < 1
      userdata = ipmitoolcmd([ "user", "list", channel ])
      @users = parse(userdata)
    end
    @users
  end

  def privlevel?(user)
    userlist[user][:priv].downcase
  end

  def userexists?(user)
    ! userlist[user].nil?
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
    userdata = ipmitoolcmd([ "user", "list", CHANNEL_LOOKUP.fetch(Facter.value(:manufacturer), '1')])
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

  def channel
    CHANNEL_LOOKUP.fetch(Facter.value(:manufacturer), '1')
  end

end
