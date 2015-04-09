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

class server::icingaweb (
  $db_password,
) {
  include server::php
  include site::ldap

  $db_hosts       = query_nodes('Class[roles::postgresql]','ipaddress_eth0')
  $db_host        = $db_hosts[0]
  $db_port        = 5432

  $icinga_db_name = 'icinga'
  $icinga_db_user = 'icinga'
  $icinga_db_pass = hiera('server::icinga::db_password')

  $db_name        = 'icingaweb'
  $db_user        = 'icingaweb'

  # Web interface database
  @@postgresql::server::db {$db_name:
    user     => $db_user,
    password => postgresql_password($db_user,$db_password),
  }

  # Install icinga-web2
  $install_path = '/usr/share/icingaweb'
  include ::git
  vcsrepo {$install_path:
    ensure   => present,
    source   => 'https://github.com/Icinga/icingaweb2.git',
    provider => 'git',
    revision => 'v2.0.0-beta3',
    require  => Class['git'],
  }

  # Configure
  $config_dir = '/etc/icingaweb'
  file {$config_dir:
    ensure => directory,
    owner  => 'apache',
  }

  # Serve on a new vhost
  $path     = '/admin/icinga'
  $web_root = "${install_path}/public"
  $www_port = 8090
  include ::apache::mod::rewrite
  include ::apache::mod::php
  ::apache::mod {'env': }
  ::apache::vhost {'icingaweb':
    port                => $www_port,
    docroot             => '/var/www/html',
    aliases             => {
      alias             => $path,
      path              => $web_root,
    },
    require             => Vcsrepo[$install_path],
  }

  apacheplus::location {$web_root:
    vhost           => 'icingaweb',
    type            => 'Directory',
    ldap_require    => "ldap-group ${site::ldap::group_id}=${site::admin_group},${site::ldap::group_dn}",
    options         => 'SymLinksIfOwnerMatch',
    custom_fragment => "
     SetEnv ICINGAWEB_CONFIGDIR '${config_dir}'
     EnableSendfile Off
     RewriteEngine on
     RewriteBase ${path}/
     RewriteCond %{REQUEST_FILENAME} -s [OR]
     RewriteCond %{REQUEST_FILENAME} -l [OR]
     RewriteCond %{REQUEST_FILENAME} -d
     RewriteRule ^.*$ - [NC,L]
     RewriteRule ^.*$ index.php [NC,L]
    "
  }

  # Pass authentication to the 'icingaweb' vhost
  client::proxy::connection {$path:
    port       => $www_port,
    chain_auth => true,
  }

  # Database abstraction
  ::php::extension {'pgsql':
    ensure  => present,
    package => 'php-pgsql',
  }
  ::php::extension {'xml':
    ensure  => present,
    package => 'php-xml',
  }

}
