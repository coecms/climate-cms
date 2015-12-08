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

# Setup icinga client & monitor host basics
class client::icinga {

  $server_ip = query_nodes('Class[server::icinga]','ipaddress_eth0')
  $allowed_hosts = ['127.0.0.1',$server_ip]

  class {'::nrpe':
    allowed_hosts => $allowed_hosts,
    purge         => true,
    recurse       => true,
  }

  client::icinga::check_process {'nrpe':
    user => 'nrpe',
  }

  client::icinga::check_nrpe {'disk':
    nrpe_plugin      => 'check_disk',
    nrpe_plugin_args => '-w 10% -c 5% -p /',
  }

  @@icinga2::object::host { $::fqdn:
    display_name     => $::hostname,
    ipv4_address     => $::ipaddress_eth0,
    target_file_name => "${::fqdn}.conf",
    vars             => {
      'hostname'     => $::site::hostname,
      'domain'       => $::site::domain,
    }
  }

  # Allow Icinga to connect to run nrpe checks
  firewall {'300 nrpe checks':
    proto  => 'tcp',
    source => $server_ip,
    dport  => '5666',
    action => 'accept',
  }

}
