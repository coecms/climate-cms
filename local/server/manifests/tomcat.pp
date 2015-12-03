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

class server::tomcat {

  include ::epel
  include ::apache
  include site::java
  include site::ldap

  $catalina_home = '/usr/share/tomcat'
  $java_home     = '/usr/lib/jvm/jre'
  $user          = 'v45_apache'

  class {'::tomcat':
    install_from_source => false,
    manage_user         => false,
  }

  tomcat::instance {'default':
    package_name => 'tomcat',
    require      => Class['epel'],
  }

  file_line {'tomcat user':
    path    => "${catalina_home}/conf/tomcat.conf",
    line    => "TOMCAT_USER=\"${user}\"",
    match   => '^TOMCAT_USER=.*',
    require => Tomcat::Instance['default'],
    notify  => Tomcat::Service['default'],
  }

  # The tomcat init script does `chown ${TOMCAT_USER}:${TOMCAT_USER}, so make
  # sure that group exists
  $group = $user
  group {$group:
    ensure => present,
  }

  tomcat::service {'default':
    use_init     => true,
    service_name => 'tomcat',
    require      => Tomcat::Instance['default'],
  }

  client::icinga::check_process {'tomcat':
    command  => 'java',
    argument => 'org.apache.catalina.startup.Bootstrap start',
    user     => $user,
  }

  package {['log4j','tomcat-native']:
    notify => Tomcat::Service['default'],
  }

  augeas {'tomcat LDAP authentication':
    incl    => "${catalina_home}/conf/server.xml",
    lens    => 'Xml.lns',
    context => "/files/${catalina_home}/conf/server.xml/Server/Service/Engine/Realm",
    changes => [
      'defnode ldap Realm[#attribute/className="org.apache.catalina.realm.JNDIRealm"] ""',
      'set $ldap/#attribute/className     "org.apache.catalina.realm.JNDIRealm"',
      "set \$ldap/#attribute/connectionURL '${site::ldap::url}'",
      "set \$ldap/#attribute/userPattern   '${site::ldap::user_pattern}'",
      "set \$ldap/#attribute/roleBase      '${site::ldap::group_dn}'",
      "set \$ldap/#attribute/roleName      '${site::ldap::group_id}'",
      "set \$ldap/#attribute/roleSearch    '(${site::ldap::group_member}={1})'",
    ],
    notify  => Tomcat::Service['default'],
  }

  # Install LDAP cert
  # http://docs.oracle.com/cd/E19509-01/820-3399/ggfrj/index.html
  $keystore  = "${java_home}/lib/security/cacerts"
  $pass      = 'changeit'
  java_ks { 'apache-self-signed':
    ensure       => latest,
    certificate  => '/etc/pki/tls/certs/localhost.crt',
    trustcacerts => true,
    target       => $keystore,
    password     => $pass,
    require      => Class['apache'],
  }

  # Reload Tomcat when keys change
  Java_ks<||> ~> Tomcat::Service['default']

  # Firewall port
  firewall {'808 proxy to tomcat':
    proto   => 'tcp',
    dport   => '8080',
    source  => $::site::proxy_ip,
    action  => 'accept',
  }

  # Path to webapp working directory
  $content_path = '/var/lib/tomcat/content'

  file {$content_path:
    ensure  => directory,
    owner   => $user,
    group   => $user,
    require => Tomcat::Instance['default'],
  }

  file {"${catalina_home}/content":
    ensure  => link,
    target  => $content_path,
    require => Tomcat::Instance['default'],
  }

  client::backup::directory {$content_path:
  }

}
