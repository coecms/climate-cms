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

# Connect a path on the local machine to the proxy server
define client::proxy::connection (
  $proxy_path            = $name,

  $protocol              = 'http',
  $target_host           = $::ipaddress_eth0,
  $port                  = 8080,
  $target_path           = $name,

  $type                  = undef,
  $order                 = undef,
  $allow                 = undef,
  $deny                  = undef,
  $chain_auth            = undef,
  $check_auth            = undef,
  $location_priority     = undef,

  $nocanon               = undef,
) {

  $proxy_ip = query_nodes('Class[server::proxy]','ipaddress_eth0')

  firewall {"400 proxy connection to ${name}":
    proto  => 'tcp',
    dport  => $port,
    source => $proxy_ip,
    action => 'accept',
  }

  @@server::proxy::connection {$name:
    path                  => $proxy_path,
    type                  => $type,
    target_url            => "${protocol}://${target_host}:${port}${target_path}",
    order                 => $order,
    allow                 => $allow,
    deny                  => $deny,
    chain_auth            => $chain_auth,
    check_auth            => $check_auth,
    location_priority     => $location_priority,
    nocanon               => $nocanon,
  }
}
