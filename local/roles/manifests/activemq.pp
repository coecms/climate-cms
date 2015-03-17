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

# Middleware server for mcollective
class roles::activemq (
  $admin_username,
  $admin_password,
  $mcollective_password,
  $keystore_password,
) {

  $package = 'activemq'
  $user    = 'activemq'
  $service = 'activemq'
  $config  = '/etc/activemq/activemq.xml'

  package {$package: }
  user {$user:
    require => Package[$package],
  }
  file {$config:
    owner   => $user,
    group   => 'root',
    mode    => '0600',
    content => template('roles/activemq/activemq.xml.erb'),
    notify  => Service[$service],
    require => Package[$package],
  }
  service {$service:
    require => Package[$package],
  }

  # Create a link to the correct datapath
  file {'/usr/share/activemq/activemq-data':
    ensure  => link,
    target  => '/usr/share/activemq/data',
    require => Package[$package],
    notify  => Service[$service],
  }

  $clients = query_nodes('Class[site::mcollective]',
                          ipaddress_eth0)

  # Puppetlabs-firewall doesn't support using a list as the source, so do a
  # workaround
  roles::activemq::firewall {$clients:}

  # Use the same keys as Puppet
  $truststore = '/etc/activemq/truststore.jks'
  $keystore   = '/etc/activemq/keystore.jks'
  include site::puppet
  java_ks { 'activemq truststore':
    ensure       => latest,
    certificate  => $site::puppet::ca,
    password     => $keystore_password,
    trustcacerts => true,
    target       => $truststore,
    notify       => File[$truststore],
    require      => Package[$package],
  }
  java_ks { 'activemq keystore':
    ensure       => latest,
    certificate  => $site::puppet::cert,
    private_key  => $site::puppet::key,
    password     => $keystore_password,
    target       => $keystore,
    notify       => File[$keystore],
    require      => Package[$package],
  }

  file {[$truststore, $keystore]:
    ensure => present,
    owner  => 'activemq',
    group  => 'root',
    mode   => '0600',
    notify => Service[$service],
  }
}
