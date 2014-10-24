require 'spec_helper'

describe :bmc_device_present, :type => :fact do
  before :each do
    Facter.clear

  end

  it 'fact name to be present' do
    expect(Facter.list.include?(:bmc_device_present)).to be true
  end

  describe 'without device' do
    it do
      expect(Facter.fact(:bmc_device_present).value).to be false

    end

  end

  describe 'with device' do

    it "/dev/ipmi0" do
      File.stubs(:exists?).with("/dev/ipmi0").returns(true)
      expect(Facter.fact(:bmc_device_present).value).to be true
    end

    it "/dev/ipmi/0" do
      File.stubs(:exists?).with("/dev/ipmi0").returns(false)
      File.stubs(:exists?).with("/dev/ipmi/0").returns(true)
      expect(Facter.fact(:bmc_device_present).value).to be true
    end

    it "/dev/ipmidev/0" do
      File.stubs(:exists?).with("/dev/ipmi0").returns(false)
      File.stubs(:exists?).with("/dev/ipmi/0").returns(false)
      File.stubs(:exists?).with("/dev/ipmidev/0").returns(true)
      expect(Facter.fact(:bmc_device_present).value).to be true
    end
  end

end