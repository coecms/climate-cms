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
  $home       = $::amanda::params::homedir
  $group      = $::amanda::params::group
  $config_dir = $::amanda::params::configs_directory

  $base_dir    = '/var/amanda'
  $tape_dir    = '/scratch/vtapes'
  $holding_dir = '/scratch/holding'
  $state_dir   = "${base_dir}/state"
  $curinfo_dir = "${state_dir}/curinfo"
  $log_dir     = '/var/log/amanda'
  $index_dir   = "${state_dir}/index"

  $mirror_user = 'v45_apache'
  $mirror_dir  = '/g/data1/ua8/climate-cms-backups'

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
    $state_dir,
    $curinfo_dir,
    $log_dir,
    $index_dir,
  ]:
    ensure => directory,
  }
  file {$holding_dir:
    ensure  => directory,
    require => Class['client::scratchdisk'],
  }

  # Create a ssh key and store in fact '${user}_sshkey'
  ::sshkey::fact {$user:}

  # Send mail to root
  mailalias {$user:
    recipient => 'root',
  }

  # Run the backups
  ::server::backup::config {'daily':
  }
  file {'/usr/sbin/backup_and_mirror':
    ensure  => file,
    mode    => '0700',
    owner   => 'root',
    group   => 'root',
    content => template('server/backup/backup_and_mirror.sh.erb'),
  }
  site::cron {'run_backups':
    command => '/usr/sbin/backup_and_mirror',
    hour    => 1,
    minute  => fqdn_rand(60,'amanda'),
  }

  # Setup the recovery config
  file {"${config_dir}/amanda-client.conf":
    content => template('server/backup/amanda-client.conf.erb'),
  }

  # Keys
  package {['pwgen','sharutils','aespipe',]:}
  file {'/usr/sbin/setup_amanda_keys':
    ensure => file,
    mode   => '0500',
    source => 'puppet:///modules/server/backup/setup_encrypt.sh',
  }
  exec {'setup keys':
    command => '/usr/sbin/setup_amanda_keys',
    user    => $user,
    creates => "${home}/.am_passphrase",
    require => File['/usr/sbin/setup_amanda_keys'],
  }
  file {"${home}/.gnupg":
    ensure => directory,
    mode   => '0700',
  }
  file {"${home}/.gnupg/am_key.gpg":
    ensure  => file,
    mode    => '0400',
    require => Exec['setup keys'],
  }
  file {"${home}/.am_passphrase":
    ensure  => file,
    mode    => '0400',
    require => Exec['setup keys'],
  }

}
