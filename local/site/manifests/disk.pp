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

# Format drives
class site::disk {

  site::partition {'local disk':
    id         => '2',
    disk       => '/dev/vda',
    type       => 'primary',
    filesystem => 'ext4',
    start      => '10.7GB',
    end        => '100%',
    mount      => '/local',
  }

  client::icinga::check_nrpe {'local-disk':
    display_name     => '/local',
    nrpe_plugin      => 'check_disk',
    nrpe_plugin_args => '-w 10% -c 5% -p /dev/vda2',
  }
}
