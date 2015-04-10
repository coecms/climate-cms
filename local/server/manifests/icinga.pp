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
    purge_configs          => true,
    require                => Class['postgresql::client'],
  }

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
      '"-H"'  => '"$address$"',
      '"-c"'  => '"$nrpe_command$"',
    },
  }

  # Collect objects to monitor
  Icinga2::Object::Host   <<||>>
  Server::Icinga::Service <<||>>

  # Monitor the service
  client::icinga::check_process {'icinga2':
    user => 'icinga',
  }

  # Notifications
  package {'mailx':}

  icinga2::object::user {'saw562':
    email  => 'saw562@nci.org.au',
    groups => ['fe2_2','access.admin'],
  }

  icinga2::object::usergroup {'access.admin':
  }
  icinga2::object::apply_notification_to_host {'accessdev-host-notifications':
    assign_where => 'host.vars.domain == "accessdev.nci.org.au"',
    command      => 'mail-host-notification',
    user_groups  => ['access.admin'],
  }
  icinga2::object::apply_notification_to_service {'accessdev-services-notifications':
    assign_where => 'host.vars.domain == "accessdev.nci.org.au"',
    command      => 'mail-service-notification',
    user_groups  => ['access.admin'],
  }

  icinga2::object::usergroup {'fe2_2':
  }
  icinga2::object::apply_notification_to_host {'climate-host-notifications':
    assign_where => 'host.vars.domain == "climate-cms.nci.org.au"',
    command      => 'mail-host-notification',
    user_groups  => ['fe2_2'],
  }
  icinga2::object::apply_notification_to_service {'climate-service-notifications':
    assign_where => 'host.vars.domain == "climate-cms.nci.org.au"',
    command      => 'mail-service-notification',
    user_groups  => ['fe2_2'],
  }

  icinga2::object::servicegroup {'service':
    assign_where => 'service.vars.nrpe_plugin == "check_procs"',
  }
  icinga2::object::servicegroup {'web':
    assign_where => 'service.vars.nrpe_plugin == "check_http"',
  }
  icinga2::object::servicegroup {'disk':
    assign_where => 'service.vars.nrpe_plugin == "check_disk"',
  }


  $cmd_user = 'icingacmd'
  $cmd_group = 'icinga'
  $cmd_home = '/var/icingacmd'
  $cmd_path = "${cmd_home}/commands"

  user {$cmd_user:
    gid    => $cmd_group,
    home   => $cmd_home,
    system => true,
  }

  file {$cmd_home:
    ensure => directory,
    owner  => $cmd_user,
    group  => $cmd_group,
    mode   => '0750',
  }

  class {'icinga2::feature::command':
    command_path => $cmd_path,
  }

}
