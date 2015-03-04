saw-ferret
==========

Installs NOAA's [Ferret](http://ferret.pmel.noaa.gov/Ferret) visualisation tool

Usage
-----

Install to `/usr/local/ferret`

```Puppet
include ::ferret
```

### Class ferret

```Puppet
class {'ferret':
  install_path        => '/usr/local/ferret' # Path to install Ferret
  manage_dependencies => false               # Install libX11
}
```

Developing
----------

The development tools make use of [bundler](http://bundler.io/)

Install development libraries with

    bundle config build.nokogiri --use-system-libraries
    bundle install --path vendor

Run unit tests with

    bundle exec rake spec

Run integration tests on a Vagrant VM with

    bundle exec rake acceptance

See the [Beaker workflow
documentation](https://github.com/puppetlabs/beaker/wiki/How-to-Write-a-Beaker-Test-for-a-Module#typical-workflow)
for how to re-use the test VM.
