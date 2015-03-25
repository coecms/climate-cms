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
class server::puppet {

  package { 'puppetserver':
    ensure => present,
  }
  service { 'puppetserver':
    ensure    => running,
    enable    => true,
    require   => Package['puppetserver'],
  }

  class {'r10k':
    remote                 => 'https://github.com/coecms/climate-cms',
    manage_ruby_dependency => 'ignore',
  }

  file {'/etc/puppet/hiera.yaml':
    ensure => link,
    target => '/etc/puppet/environments/production/hiera.yaml',
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
    group  => 'puppet',
    mode   => '0700',
  }
  augeas { 'private fileserver':
    lens    => 'Puppetfileserver.lns',
    incl    => '/etc/puppet/fileserver.conf',
    changes => [
      "set private/path '${private_path}'",
      'set private/allow "*"',
    ],
    notify  => Service['puppetserver'],
  }

  include server::puppet::ca
  include server::puppet::reports
}