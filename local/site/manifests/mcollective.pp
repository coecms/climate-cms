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
class site::mcollective (
  $password, # Must be definied by the caller
) {
  include site::puppet

  # Certificates are generated on the Puppetmaster, using the Puppet CA, in
  # roles::puppetmaster. Client certificates for admin users should be
  # configured in /etc/puppet/private/mcollective/clients on the puppetmaster

  # Get middleware hosts from puppetdb
  $middleware_hosts = query_nodes('Class[roles::activemq]',
                                  hostname)

  $shared_name = 'mcollective-servers'

  class {'::mcollective':
    client              => true,
    middleware_hosts    => $middleware_hosts,
    middleware_ssl      => true,
    middleware_password => $password,
    securityprovider    => 'ssl',
    ssl_ca_cert         => "file://${puppet::ca}",
    ssl_server_public   => 'puppet:///private/mcollective/certs/mcollective-shared.pem',
    ssl_server_private  => 'puppet:///private/mcollective/keys/mcollective-shared.pem',
    ssl_client_certs    => 'puppet:///private/mcollective/clients'
  }

  ::mcollective::plugin {['puppet','service']:
    package => true,
  }

  # User for Mcollective requests
  $user = 'mcollective'
  $home = '/var/mco-user'

  user {$user:
    home       => $home,
    system     => true,
    shell      => '/sbin/nologin',
  }

  file {$home:
    ensure => directory,
    owner  => $user,
  }

  ::mcollective::user { $user:
    username    => $user,
    homedir     => $home,
    certificate => 'puppet:///private/mcollective/certs/mcollective-user.pem',
    private_key => 'puppet:///private/mcollective/keys/mcollective-user.pem',
    require     => File[$home],
  }

}
