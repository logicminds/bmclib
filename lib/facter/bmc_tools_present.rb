# not sure how to look for the device in windows
Facter.add(:bmc_tools_present) do
  setcode do
    !Facter::Core::Execution.which('ipmitool').nil?
  end
end