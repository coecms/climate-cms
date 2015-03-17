## Copyright 2015 ARC Centre of Excellence for Climate Systems Science
#
#  \author  Scott Wales <scott.wales@unimelb.edu.au>
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

# Site defaults for mcollective
class site::mcollective {

  # Get middleware hosts from puppetdb
  $middleware_hosts = query_nodes('Class[roles::activemq]',
                                  hostname)

  class {'::mcollective':
    client           => true,
    middleware_hosts => $middleware_hosts,
  }

  ::mcollective::plugin {['puppet','service']:
    package => true,
  }

  # User for Mcollective requests
  user {'mcollective':
    system => true,
    shell  => '/sbin/nologin',
  }

  include site::puppet

  $shared_name        = 'mcollective-servers'
  $shared_server_cert = "${puppet::certdir}/${shared_name}.pem"
  $shared_server_key  = "${puppet::privatekeydir}/${shared_name}.pem"

  $server_cert = "${puppet::certdir}/${site::hostname}.pem"
  $server_key  = "${puppet::privatekeydir}/${site::hostname}.pem"

  file {$shared_server_cert:
    ensure => present,
    source => "puppet:///private/certs/${shared_name}.pem",
    mode   => '0555',
    owner  => 'root',
    group  => 'root',
  }
  file {$shared_server_key:
    ensure => present,
    source => "puppet:///private/private_keys/${shared_name}.pem",
    mode   => '0500',
    owner  => 'root',
    group  => 'root',
  }

}
