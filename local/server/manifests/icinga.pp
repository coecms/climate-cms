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

# Icinga monitors services and sends notifications if they go down
class server::icinga (
  $db_password,
) {

  $db_hosts = query_nodes('Class[roles::postgresql]','ipaddress_eth0')
  $db_host  = $db_hosts[0]
  $db_port  = 5432
  $db_name  = 'icinga'
  $db_user  = 'icinga'

  # Install DB
  @@postgresql::server::db {$db_name:
    user     => $db_user,
    password => postgresql_password($db_user,$db_password),
  }

  include ::postgresql::client

  # Install server
  class {'icinga2':
    db_type                => 'pgsql',
    db_host                => $db_host,
    db_port                => $db_port,
    db_name                => $db_name,
    db_user                => $db_user,
    db_pass                => $db_password,
    install_nagios_plugins => false,
    require                => Class['postgresql::client'],
  }

  # Monitor the service
  client::icinga::check_service {'icinga2':}

  # Install connector
  icinga2::object::idopgsqlconnection { 'postgres_connection':
    host             => $db_host,
    port             => $db_port,
    user             => $db_user,
    password         => $db_password,
    database         => $db_name,
    categories       => [
      'DbCatConfig',
      'DbCatState',
      'DbCatAcknowledgement',
      'DbCatComment',
      'DbCatDowntime',
      'DbCatEventHandler' ],
  }

  icinga2::object::checkcommand {'check_nrpe':
    command   => ['"/check_nrpe"'],
    arguments => {
      '"-H"'  => '"$HOSTADDRESS$"',
      '"-c"'  => '"$nrpe_command$"',
    },
  }

  # Collect objects to monitor
  Icinga2::Object::Host    <<||>>
  Icinga2::Object::Service <<||>>

}
