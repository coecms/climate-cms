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

  class {'::activemq':
    mq_admin_username => $admin_username,
    mq_admin_password => $admin_password,
    server_config     => template('roles/activemq/activemq.xml.erb'),

    # See https://github.com/puppetlabs/puppetlabs-activemq/pull/31
    version           => '5.9.1-2.el6',
    before            => Class['mcollective'],
  }

  # Create a link to the correct datapath
  file {'/usr/share/activemq/activemq-data':
    ensure  => link,
    target  => '/usr/share/activemq/data',
    require => Package['activemq'],
    notify  => Service['activemq'],
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
  java_ks { 'puppetca:activemq':
    ensure       => latest,
    certificate  => $site::puppet::ca,
    password     => $keystore_password,
    trustcacerts => true,
    target       => $truststore,
    notify       => File[$truststore],
    require      => Class['::activemqi::packages'],
  }
  java_ks { 'puppetcert:activemq':
    ensure       => latest,
    certificate  => $site::puppet::cert,
    private_key  => $site::puppet::key,
    password     => $keystore_password,
    target       => $keystore,
    notify       => File[$keystore],
    require      => Class['::activemq::packages'],
  }

  file {[$truststore, $keystore]:
    ensure => present,
    owner  => 'activemq',
    group  => 'root',
    mode   => '0600',
    notify => Class['::activemq::service'],
  }
}
