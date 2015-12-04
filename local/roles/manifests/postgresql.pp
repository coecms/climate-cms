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

class roles::postgresql (
  $admin_password,
) {

  class {'::postgresql::server':
    ip_mask_allow_all_users    => '10.0.0.0/16',
    listen_addresses           => '*',
    postgres_password          => $admin_password,
  }

  # Collect all defined databases
  ::Postgresql::Server::Db <<||>>

  # Nodes that are using databases
  $db_clients_ip = query_nodes('@@Postgresql::Server::Db[~".*"]','ipaddress_eth0')
  roles::postgresql::firewall {$db_clients_ip:}
}
