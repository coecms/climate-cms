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
  class {'::icingaweb2':
    auth_backend => 'external',

    ido_db       => 'pgsql',
    ido_db_host  => $db_host,
    ido_db_port  => $db_port,
    ido_db_name  => $icinga_db_name,
    ido_db_user  => $icinga_db_user,
    ido_db_pass  => $icinga_db_pass,

    web_db       => 'pgsql',
    web_db_host  => $db_host,
    web_db_port  => $db_port,
    web_db_name  => $db_name,
    web_db_user  => $db_user,
    web_db_pass  => $db_password,
  }

  # Serve on a new vhost
  $www_port = 8090
  include ::apache::mod::rewrite
  include ::apache::mod::php
  ::apache::vhost {'icingaweb':
    port                => $www_port,
    docroot             => $::icingaweb2::web_root,
    directories         => [
      {'path'           => $::icingaweb2::web_root,
      'provider'        => 'directory',
      'options'         => 'SymLinksIfOwnerMatch',
      'custom_fragment' => "
       SetEnv ICINGAWEB_CONFIGDIR '${::icingaweb2::config_dir}'
       EnableSendfile Off
       RewriteEngine on
       RewriteBase /icingaweb2/
       RewriteCond %{REQUEST_FILENAME} -s [OR]
       RewriteCond %{REQUEST_FILENAME} -l [OR]
       RewriteCond %{REQUEST_FILENAME} -d
       RewriteRule ^.*$ - [NC,L]
       RewriteRule ^.*$ index.php [NC,L]
      "
      }],
  }


}
