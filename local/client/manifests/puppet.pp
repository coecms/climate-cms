## \file    local/site/manifests/puppet.pp
#  \author  Scott Wales <scott.wales@unimelb.edu.au>
#
#  Copyright 2015 ARC Centre of Excellence for Climate Systems Science
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

class client::puppet (
  $master = 'puppet',
) {

  if versioncmp($::puppetversion, '4.0.0') >= 0 {
    $package = 'puppet-agent'
    $config  = '/etc/puppetlabs/puppet/puppet.conf'
    $codedir = '/etc/puppetlabs/code'

    file {'/usr/bin/puppet':
      ensure  => link,
      target  => '/opt/puppetlabs/bin/puppet',
      require => Package[$package],
    }
  } else {
    $package = 'puppet'
    $config  = '/etc/puppet/puppet.conf'
    $codedir = '/etc/puppet'
  }

  package { $package:
    ensure => present,
  }

  file { $config:
    require => Package[$package],
  }

  service { 'puppet':
    enable  => true,
    require => Package[$config],
  }

  augeas { 'puppetmaster':
    lens    => 'Puppet.lns',
    incl    => $config,
    changes => [
      "set agent/server '${master}'",
    ],
    require => File[$config],
    notify  => Service['puppet'],
  }

  $certdir       = '/var/lib/puppet/ssl/certs'
  $privatekeydir = '/var/lib/puppet/ssl/private_keys'

  $ca   = "${certdir}/ca.pem"
  $cert = "${certdir}/${site::hostname}.pem"
  $key  = "${privatekeydir}/${site::hostname}.pem"

  file {[$certdir,$privatekeydir,$ca,$cert,$key]:}

  # Monitor agent run results
  @@server::puppet::monitor_agent {$::hostname:}

}
