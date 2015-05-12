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

# Installs a salt master
#
# Salt is a way to run commands on multiple computers at once, for instance if
# you run on the salt master
#
#    salt '*' puppet.run agent test
#
# Puppet will be run on every salt client instance

class server::salt {

  # Install master
  class {'::salt::master':
  }

  # Allow minions to see the master
  $client_ips = query_nodes('Class[client::salt]','ipaddress_eth0')
  server::salt::firewall {$client_ips:
  }

  # Allow jenkins to connnect to the salt server so it can test the nodes
  include client::jenkins
  sudo::conf {'jenkins-salt':
    content => 'jenkins root = NOPASSWD: salt'
  }

}
