require 'spec_helper'

describe 'bmclib', :type => :class do

  describe "On a debian system" do
    let(:facts) {{ :osfamily => 'Debian' }}
    it { should contain_package('ipmidriver').with_name('openipmi') }
  end

  describe "On any other system" do
    let(:facts) {{ :osfamily => 'RedHat' }}
    it { should contain_package('ipmidriver').with_name('OpenIPMI') }
  end

  # TODO: We should probably fail on systems that we dont know 
  # How to handle. 
  # http://docs.puppetlabs.com/guides/style_guide.html#defaults-for-case-statements-and-selectors
  # describe "On an unknown system" do
  #  let(:facts) {{ :osfamily => 'Unknown' }}
  #end

end
