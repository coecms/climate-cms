require 'spec_helper'

describe 'las' do
  context 'supported operating systems' do
    ['Debian', 'RedHat'].each do |osfamily|
      describe "las class without any parameters on #{osfamily}" do
        let(:params) {{ }}
        let(:facts) {{
          :osfamily => osfamily,
        }}

        it { should compile.with_all_deps }

        it { should contain_class('las::params') }
        it { should contain_class('las::install').that_comes_before('las::config') }
        it { should contain_class('las::config') }
        it { should contain_class('las::service').that_subscribes_to('las::config') }

        it { should contain_service('las') }
        it { should contain_package('las').with_ensure('present') }
      end
    end
  end

  context 'unsupported operating system' do
    describe 'las class without any parameters on Solaris/Nexenta' do
      let(:facts) {{
        :osfamily        => 'Solaris',
        :operatingsystem => 'Nexenta',
      }}

      it { expect { should contain_package('las') }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end
end
