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

class server::ramadda (
  $db_password,
  $version = '2.1b',
) {
  include server::tomcat

  $source_url = "http://downloads.sourceforge.net/project/ramadda/ramadda${version}"
  $ramadda_home = "${server::tomcat::content_path}/ramadda"

  include server::ramadda::ncl

  tomcat::war {'repository.war':
    catalina_base => $server::tomcat::catalina_home,
    war_source    => "${source_url}/repository.war",
    notify        => Tomcat::Service['default'],
  }

  client::proxy::connection {'/repository':
    allow      => 'from all',
    protocol   => 'ajp',
    port       => '8009',
  }

  file {"${server::tomcat::catalina_home}/conf/repository.properties":
    ensure  => file,
    content => "ramadda_home=${ramadda_home}\n",
    require => Tomcat::Instance['default'],
    notify  => Tomcat::Service['default'],
  }

  file {$ramadda_home:
    ensure => directory,
    owner  => $server::tomcat::user,
    group  => $server::tomcat::group,
  }

  @@postgresql::server::db {'ramadda':
    user     => 'ramadda',
    password => postgresql_password('ramadda',$db_password)
  }

  $db_config = "
    ramadda.db=postgres
    ramadda.db.postgres.url=jdbc:postgresql://db/ramadda
    ramadda.db.postgres.user=ramadda
    ramadda.db.postgres.password=${db_password}
  "
  file {"${ramadda_home}/db.properties":
    ensure  => file,
    content => $db_config,
    notify  => Tomcat::Service['default'],
  }

  file {"${ramadda_home}/plugins":
    ensure  => directory,
  }
  staging::file {'ldapplugin.jar':
    source  => "${source_url}/plugins/ldapplugin.jar",
    target  => "${ramadda_home}/plugins/ldapplugin.jar",
    require => File["${ramadda_home}/plugins"],
    notify  => Tomcat::Service['default'],
  }

  $ldap_config = "
    ldap.url=${site::ldap::url}
    ldap.user.directory=${site::ldap::user_id}=\${id},${site::ldap::user_dn}
    ldap.group.directory=${site::ldap::group_dn}
    ldap.group.attribute=${site::ldap::group_member}
    ldap.group.admin=${site::admin_group}
  "
  file {"${ramadda_home}/ldap.properties":
    ensure  => file,
    content => $ldap_config,
    notify  => Tomcat::Service['default'],
  }
}
