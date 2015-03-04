require 'spec_helper_acceptance'

describe 'ferret class' do

  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'should work idempotently with no errors' do
      pp = <<-EOS
      class { 'ferret': 
        manage_dependencies => true,
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes  => true)
    end

    describe command('/usr/local/ferret/bin/ferret -version') do
      its(:exit_status) { should eq 0 }
    end
  end
end
