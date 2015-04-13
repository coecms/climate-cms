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

  package { 'puppet':
    ensure => present,
  }

  file { '/etc/puppet/puppet.conf':
    require => Package['puppet'],
  }

  service { 'puppet':
    enable  => true,
    require => Package['puppet'],
  }

  augeas { 'puppetmaster':
    lens    => 'Puppet.lns',
    incl    => '/etc/puppet/puppet.conf',
    changes => [
      "set agent/server '${master}'",
    ],
    require => File['/etc/puppet/puppet.conf'],
    notify  => Service['puppet'],
  }

  $certdir       = '/var/lib/puppet/ssl/certs'
  $privatekeydir = '/var/lib/puppet/ssl/private_keys'

  $ca   = "${certdir}/ca.pem"
  $cert = "${certdir}/${site::hostname}.pem"
  $key  = "${privatekeydir}/${site::hostname}.pem"

  file {[$certdir,$privatekeydir,$ca,$cert,$key]:}

  # Monitoring
  client::icinga::check {'puppet':
    display_name => 'puppet agent',
    nrpe_plugin  => 'check_puppet_agent',
  }

  icinga2::checkplugin {'check_puppet_agent':
    checkplugin_file_distribution_method => 'source',
    source                               => 'puppet:///modules/client/puppet/check_puppet_agent',
  }

}
