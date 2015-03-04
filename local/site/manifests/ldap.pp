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

# Type to contain LDAP parameters
class site::ldap (
  $protocol     = 'ldaps://',
  $domain       = 'example.com',
  $port         = '636',
  $base_dn      = 'dc=example,dc=com',
  $user_rdn     = 'ou=People',
  $group_rdn    = 'ou=Group',
  $user_id      = 'uid',
  $group_id     = 'cn',
  $group_member = 'memberUid',
  $cert         = '',
) {
  $url          = "${protocol}${domain}:${port}"

  $user_dn      = "${user_rdn},${base_dn}"
  $user_pattern = "${user_id}={0},${user_dn}"

  $group_dn      = "${group_rdn},${base_dn}"
  $group_pattern = "${group_id}={0},${group_dn}"

  $ca_path       = '/etc/openldap/CA'
  $ca_file       = "${ca_path}/${domain}"

  file {$ca_path:
    ensure => directory,
  }
  file {$ca_file:
    ensure  => file,
    content => $cert,
    notify  => Exec['ldap rehash'],
  }
  exec {'ldap rehash':
    command     => "cacertdir_rehash '${ca_path}'",
    path        => '/usr/sbin',
    refreshonly => true,
  }

  file {'/etc/openldap/ldap.conf':
    ensure  => file,
    content => "
      URI  ${protocol}${domain}:${port}
      BASE ${base_dn}

      TLS_CACERTDIR ${ca_path}
      ",
  }

  augeas {'nsswitch':
    incl    => '/etc/nsswitch.conf',
    lens    => 'Nsswtich.lns',
    context => '/files/etc/nsswitch.conf',
    changes => [
      'set /files/etc/nsswitch.conf/database[. = "passwd"]/service "files ldap"',
      'set /files/etc/nsswitch.conf/database[. = "shadow"]/service "files ldap"',
      'set /files/etc/nsswitch.conf/database[. = "group"]/service  "files ldap"',
    ],
  }

}
