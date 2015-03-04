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

class site::tomcat {

  include ::epel
  include site::java
  include site::ldap

  $catalina_home = '/usr/share/tomcat'
  $java_home     = '/usr/lib/jvm/jre'

  class {'::tomcat':
    install_from_source => false,
  }

  tomcat::instance {'default':
    package_name => 'tomcat',
    require      => Class['epel'],
  }

  # Connect tomcat user to groups
  $projects = keys($site::gdata)
  user {'tomcat':
    groups  => $projects,
    require => Tomcat::Instance['default'],
  }

  tomcat::service {'default':
    use_init     => true,
    service_name => 'tomcat',
    require      => Tomcat::Instance['default'],
  }

  package {['log4j','tomcat-native']:
    notify => Tomcat::Service['default'],
  }

  augeas {'tomcat LDAP authentication':
    incl    => "${catalina_home}/conf/server.xml",
    lens    => 'Xml.lns',
    context => "/files/${catalina_home}/conf/server.xml/Server/Service/Engine/Realm/Realm/#attribute",
    changes => [
      'set className "org.apache.catalina.realm.JNDIRealm"',
      'rm resourceName',
      "set connectionURL '${site::ldap::url}'",
      "set userPattern   '${site::ldap::user_pattern}'",
      "set roleBase      '${site::ldap::group_dn}'",
      "set roleName      '${site::ldap::group_id}'",
      "set roleSearch    '(${site::ldap::group_member}={1})'",
    ],
    notify => Tomcat::Service['default'],
  }

  # Install LDAP cert
  # http://docs.oracle.com/cd/E19509-01/820-3399/ggfrj/index.html
  $keystore  = "${java_home}/lib/security/cacerts"
  $alias     = 'ldap'
  $pass      = 'changeit'
  exec {'tomcat LDAP cert':
    command => "keytool -import -alias '${alias}' -keystore '${keystore}' -storepass '${pass}' -file '${ldap::ca_file}' -trustcacerts -noprompt",
    unless  => "keytool -list   -alias '${alias}' -keystore '${keystore}' -storepass '${pass}'",
    path    => "${java_home}/bin",
    require => File[$ldap::ca_file],
    notify  => Tomcat::Service['default'],
  }

  # Firewall port
  firewall {'808 proxy to tomcat':
    proto   => 'tcp',
    port    => '8080',
    source  => $::site::proxy_ip,
    action  => 'accept',
  }

}
