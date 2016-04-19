## Copyright 2016 ARC Centre of Excellence for Climate Systems Science
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

define site::user (
  $mail    = undef,
  $pubkeys = [],
) {
  validate_re($name, '^[a-z]{3}[0-9]{3}$')
  $institute_code = regsubst($name,'^([a-z]{3})([0-9]{3})$','\2')
  $home = "/home/${institute_code}/${name}"

  ensure_resource(
    'file',
    "/home/${institute_code}",
    {'ensure' => 'directory'})

  # Users come from LDAP
  include site::ldap
  include site::nfsh
  user {$name:
    ensure         => absent,
    forcelocal     => true,
  }

  file {$home:
    ensure  => directory,
    owner   => $name,
    require => User[$name],
  }

  file {"${home}/.bashrc":
    ensure => present,
    owner  => $name,
    source => '/etc/skel/.bashrc',
  }
  file {"${home}/.bash_profile":
    ensure => present,
    owner  => $name,
    source => '/etc/skel/.bash_profile',
  }
  file {"${home}/.bash_logout":
    ensure => present,
    owner  => $name,
    source => '/etc/skel/.bash_logout',
  }

  site::user::pubkey {$pubkeys:
    user => $name,
  }

}
