require 'spec_helper_acceptance'

describe 'las class' do

  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'should work idempotently with no errors' do
      pp = <<-EOS
      class { 'las': 
        manage_dependencies => true,
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes  => true)
    end

    describe command('curl  -s -o /dev/null -w "%{http_code}" localhost:8080/las/UI.vm') do
      its(:stdout) { should match /^200$/ }
    end

  end
end
