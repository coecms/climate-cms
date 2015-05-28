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

# Backup Server
class server::backup {
  include ::amanda::params

  $user       = $::amanda::params::user
  $group      = $::amanda::params::group
  $config_dir = $::amanda::params::configs_directory

  $base_dir    = '/var/amanda'
  $tape_dir    = "${base_dir}/vtapes"
  $holding_dir = "${base_dir}/holding"
  $state_dir   = "${base_dir}/state"
  $curinfo_dir = "${state_dir}/curinfo"
  $log_dir     = "${state_dir}/log"
  $index_dir   = "${state_dir}/index"

  $slot_dirs   = ["${tape_dir}/slot1",
                  "${tape_dir}/slot2",
                  "${tape_dir}/slot3",
                  "${tape_dir}/slot4"]

  class {'::amanda::server':
  }

  File {
    owner   => $user,
    group   => $group,
  }

  # Setup directories
  file {$config_dir:
    ensure  => directory,
    purge   => true,
    recurse => true,
    force   => true,
  }
  file {[
    $base_dir,
    $tape_dir,
    $holding_dir,
    $state_dir,
    $curinfo_dir,
    $log_dir,
    $index_dir,
  ]:
    ensure => directory,
  }
  file {$slot_dirs:
    ensure => directory,
  }

  # Create a ssh key and store in fact 'amandabackup_sshkey'
  ::sshkey::fact {$user:}

  # Send mail to root
  mailalias {$user:
    recipient => 'root',
  }

  # Run the backups
  ::server::backup::config {'daily':
  }
  site::cron {'amdump daily':
    user   => $user,
    hour   => 1,
    minute => fqdn_rand(60),
  }

}
