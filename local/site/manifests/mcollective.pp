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
  include site::puppet

  # Get middleware hosts from puppetdb
  $middleware_hosts = query_nodes('Class[roles::activemq]',
                                  hostname)

  $shared_name = 'mcollective-servers'

  class {'::mcollective':
    client             => true,
    middleware_hosts   => $middleware_hosts,
    middleware_ssl     => true,
    securityprovider   => 'ssl',
    ssl_ca_cert        => "file://${puppet::ca}",
    ssl_server_public  => "puppet:///private/certs/${shared_name}.pem",
    ssl_server_private => "puppet:///private/private_keys/${shared_name}.pem",
    ssl_client_certs   => 'puppet:///private/agent_certs'
  }

  ::mcollective::plugin {['puppet','service']:
    package => true,
  }

  # User for Mcollective requests
  $user = 'mcollective'
  user {$user:
    system     => true,
    shell      => '/sbin/nologin',
  }

  ::mcollective::user { $user:
    user        => $user,
    certificate => 'puppet:///private/certs/mcollective-user.pem',
    private_key => 'puppet:///private/private_keys/mcollective-user.pem',
  }

}
