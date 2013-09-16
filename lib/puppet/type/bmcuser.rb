Puppet::Type.newtype(:bmcuser) do
  @doc = "Manage BMC devices"


  ensurable

  newparam(:name, :namevar=>true) do
    desc "The name of the resource"

  end

  newproperty(:username) do
    desc "The username to be added"

  end

  newproperty(:userpass) do
    desc "The password of the user to create"

  end

  newparam(:force) do
    desc "The force parameter will set the password of the user with every puppet run"
    newvalues(true, false)
  end

  newproperty(:privlevel) do
    desc "The public certificate of the user"
    newvalues(:admin, :user, :operator, :callback)
  end

  newparam(:provider) do
    desc "The type of ipmi provider to use when setting up the bmc"
    newvalues(:ipmitool)
    defaultto(:ipmitool)
  end

end