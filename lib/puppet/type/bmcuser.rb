Puppet::Type.newtype(:bmcuser) do
  @doc = "Manage BMC devices"

  ensurable

  newparam(:name, :namevar=>true) do
    desc "The name of the resource"
  end

  newproperty(:username) do
    desc "The username to be added. Defaults to the name of the resource"
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
    newvalues(:administrator, :user, :operator, :callback)
  end

end
