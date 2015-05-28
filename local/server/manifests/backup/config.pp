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

define server::backup::config (
  $config = $name,
) {
  include ::amanda::params

  $user       = $::amanda::params::user
  $group      = $::amanda::params::group
  $config_dir = $::amanda::params::configs_directory

  $tape_dir    = $server::backup::tape_dir
  $holding_dir = $server::backup::holding_dir
  $curinfo_dir = $server::backup::curinfo_dir
  $log_dir     = $server::backup::log_dir
  $index_dir   = $server::backup::index_dir
  $slot_dirs   = $server::backup::slot_dirs

  File {
    owner => $user,
    group => $group,
  }

  file {"${config_dir}/${config}/amanda.conf":
    ensure  => file,
    content => template('server/backup/amanda.conf.erb'),
  }

  ::amanda::config {$config:
    owner                    => $user,
    group                    => $group,
    configs_directory        => $config_dir,
    manage_configs_directory => false,
    configs_source           => 'modules/server/backup',
    manage_dle               => true,
  }

}
