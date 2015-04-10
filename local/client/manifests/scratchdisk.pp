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

# Mount /scratch
class client::scratchdisk {
  $target = '/scratch'

  file {$target:
    ensure => directory,
  }

  file {"${target}/data":
    ensure  => directory,
    owner   => root,
    group   => root,
    mode    => '0777',
    require => Mount[$target],
  }

  mount {$target:
    ensure  => mounted,
    atboot  => true,
    device  => '/dev/vdb',
    fstype  => 'auto',
    require => File[$target],
  }

  client::icinga::check {'scratch':
    nrpe_plugin      => 'check_disk',
    nrpe_plugin_args => "-w 10% -c 5% -p ${target}",
  }

}
