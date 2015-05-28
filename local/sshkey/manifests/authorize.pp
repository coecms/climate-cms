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

# Authorise the ssh key for a server found with a puppetdb query
define sshkey::authorize (
  $query,
  $user        = $name,
  $remote_user = $name,
) {

  $sshkey = query_nodes($query, "${remote_user}_sshkey")
  $_parts = split($sshkey[0], ' ')
  $type   = $_parts[0]
  $key    = $_parts[1]
  $host   = $_parts[2]

  ssh_authorized_key {"${host} -> ${user}":
    user => $user,
    type => $type,
    key  => $key,
  }

}
