# not sure how to look for the device in windows
Facter.add(:bmc_device_present) do
  setcode do
    File.exists?('/dev/ipmi0') || File.exists?('/dev/ipmi/0') || File.exists?('/dev/ipmidev/0')
  end
end