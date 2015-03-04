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

# Mount NCI project data
define site::gdata (
  $project  = $name,
  $server   = 'nnfs2.nci.org.au',
  $cluster  = 'data1',
) {

  $mountpoint = "/g/${cluster}/${project}"

  # Group will be defined by LDAP
  group {$project: }

  file {$mountpoint:
    ensure => directory,
  }

  mount {$mountpoint:
    ensure  => mounted,
    device  => "${server}:/mnt/g${cluster}/${project}",
    fstype  => 'nfs',
    options => 'ro,nolock',
    require => [Package['nfs-utils'],File[$mountpoint]],
  }
}
