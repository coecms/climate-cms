saw-las
=======

Installs NOAA's [LAS](http://ferret.pmel.noaa.gov/LAS) web-based visualisation tool

Usage
-----

### Class las

```Puppet
class {'las':
  las_title           => 'LAS'                # Title to add to web pages
  proxy_fqdn          => $::fqdn              # Reverse proxy FQDN
  tomcat_fqdn         => $::fqdn              # Tomcat server FQDN
  tomcat_port         => '8080'               # Tomcat port
  tomcat_user         => 'tomcat'             # Tomcat user
  catalina_home       => '/usr/share/tomcat6' # Tomcat home directory
  manage_dependencies => false                # Install all dependencies
}
```

### Dependencies

* [puppetlabs-stdlib](https://forge.puppetlabs.com/puppetlabs/stdlib)
* [puppetlabs-java](https://forge.puppetlabs.com/puppetlabs/java)
* [nanliu-staging](https://forge.puppetlabs.com/nanliu/staging)
* [saw-ferret](https://forge.puppetlabs.com/saw/ferret)

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
