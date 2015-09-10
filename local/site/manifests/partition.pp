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

define site::partition (
  $disk,
  $id,
  $mount,
  $start,
  $end,
  $type       = 'primary',
  $filesystem = 'ext4',
) {

  $volume = "${disk}${id}"

  # Create partition entry ${id}:
  exec {"parted ${volume}":
    command => "/sbin/parted -s '${disk}' mkpart '${type}' '${filesystem}' '${start}' '${end}'",
    creates => $volume,
  }

  file {$volume:
    require => Exec["parted ${volume}"],
  }

  # Format
  exec {"mkfs ${volume}":
    command => "/sbin/mkfs -t '${filesystem}' '${volume}'",
    require => File[$volume],
    unless  => "/sbin/blkid '${volume}' | /bin/grep 'TYPE=\"${filesystem}\"'",
  }

  # Mount point
  file {$mount:
    ensure => directory,
  }

  mount {$mount:
    ensure  => mounted,
    atboot  => true,
    device  => $volume,
    fstype  => $filesystem,
    require => [File[$mount],Exec["mkfs ${volume}"]],
  }

}
