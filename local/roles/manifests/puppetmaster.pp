## \file    puppetmaster.pp
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

# Server for Puppet orchestration
class roles::puppetmaster (
) {

  package { 'puppetserver':
    ensure => present,
  }
  service { 'puppetserver':
    ensure    => running,
    enable    => true,
    require   => Package['puppetserver'],
  }

  package { 'r10k':
    ensure   => present,
    provider => gem,
  }

  augeas { 'r10k':
    lens    => 'Puppet.lns',
    incl    => '/etc/puppet/puppet.conf',
    changes => 'set agent/postrun_command "/usr/bin/r10k deploy environment --puppetfile"',
    require => File['/etc/puppet/puppet.conf'],
    notify  => Service['puppet'],
  }
  augeas { 'reports':
    lens    => 'Puppet.lns',
    incl    => '/etc/puppet/puppet.conf',
    changes => [
      'set master/reports   "http"',
      'set master/reporturl "http://monitor:9200/puppet/report"',
    ],
    require => File['/etc/puppet/puppet.conf'],
    notify  => Service['puppetserver'],
  }

  firewall {'140 puppetmaster':
    proto  => 'tcp',
    port   => '8140',
    source => '10.0.0.0/16',
    action => 'accept',
  }

  class {'puppetdb::master::config':
    puppetdb_server     => $::hostname,
    puppet_service_name => 'puppetserver',
    require             => Class['puppetdb'],
  }

  # Private files to share with servers
  $private_path = '/etc/puppet/private'
  file {$private_path:
    ensure => directory,
    owner  => 'puppet',
    group  => 'root',
    mode   => '0700',
  }
  augeas { 'private fileserver':
    lens    => 'Puppet.lns',
    incl    => '/etc/puppet/fileserver.conf',
    changes => [
      "set private/path '${private_path}'",
      'set private/allow "*"',
    ],
    notify  => Service['puppetserver'],
  }

  # Generate shared host keys
  include site::mcollective
  exec {"puppet cert generate ${site::mcollective::shared_name}":
    command => "puppet cert generate ${site::mcollective::shared_name} --ssldir ${private_path}",
    path    => '/usr/bin',
    require => File[$private_path],
    creates => "${private_path}/private_keys/${site::mcollective::shared_name}.pem",
  }
}
