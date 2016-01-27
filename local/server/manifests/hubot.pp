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

# Hubot is a chat bot, used on the slack room
class server::hubot (
  $slack_token,
) {
  $user         = 'hubot'
  $group        = 'hubot'
  $install_path = '/opt/hubot'

  include ::site::nodejs

  user {$user:
    ensure     => present,
    gid        => $group,
    system     => true,
    shell      => '/bin/false',
    managehome => true,
  }
  group {$group:
    ensure => present,
  }

  vcsrepo {$install_path:
    ensure   => latest,
    provider => 'git',
    source   => 'https://github.com/ScottWales/hubot',
    notify   => Supervisord::Program['hubot'],
  }

  # $user needs to install node packages here
  file {"${install_path}/node_modules":
    ensure  => directory,
    owner   => $user,
    require => Vcsrepo[$install_path],
  }

  # Keep the bot running with supervisord
  include ::supervisord
  supervisord::program {'hubot':
    command               => "${install_path}/bin/hubot --adapter slack",
    user                  => $user,
    directory             => $install_path,
    program_environment   => {
      'HUBOT_SLACK_TOKEN' => $slack_token,
    },
    require               => File["${install_path}/node_modules"],
  }

}
