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

class roles::thredds {
  include server::tomcat

  $admin_group = $site::admin_group

  tomcat::war {'thredds.war':
    catalina_base => $server::tomcat::catalina_home,
    war_source    => 'ftp://ftp.unidata.ucar.edu/pub/thredds/4.3/current/thredds.war',
    notify        => Tomcat::Service['default'],
    require       => File["${server::tomcat::catalina_home}/content"],
  }

  client::proxy::connection {'/thredds':
    allow    => 'from all',
    protocol => 'ajp',
    port     => '8009',
  }

  $web_xml = "${server::tomcat::catalina_home}/webapps/thredds/WEB-INF/web.xml"
  # Extract the war so we can change configs
  file {"${server::tomcat::catalina_home}/webapps/thredds":
    ensure => directory,
  }
  staging::extract {'thredds.war':
    target  => "${server::tomcat::catalina_home}/webapps/thredds",
    source  => "${server::tomcat::catalina_home}/webapps/thredds.war",
    creates => $web_xml,
    require => Tomcat::War['thredds.war'],
  }

  augeas {'thredds security':
    incl    => $web_xml,
    lens    => 'Xml.lns',
    context => "/files/${web_xml}/web-app",
    changes => [
      'defnode authrole security-role[role-name/#text="*"] ""',
      'set    $authrole/role-name/#text   "*"',
      'set    $authrole/description/#text "Authenticated User"',
      'defnode admin security-constraint[web-resource-collection/url-pattern/#text="/admin/*"] ""',
      "set   \$admin/auth-constraint/role-name/#text '${admin_group}'",
      'defnode trig security-constraint[web-resource-collection/url-pattern/#text="/admin/collection/trigger"] ""',
      "set   \$trig/auth-constraint/role-name/#text '${admin_group}'",
      'defnode log security-constraint[web-resource-collection/url-pattern/#text="/admin/log/*"] ""',
      "set   \$log/auth-constraint/role-name/#text '${admin_group}'",
      'defnode gen security-constraint[web-resource-collection/url-pattern/#text="/cataloggen/admin/*"] ""',
      "set   \$gen/auth-constraint/role-name/#text '${admin_group}'",
      'defnode auth security-constraint[web-resource-collection/url-pattern/#text="/restrictedAccess/*"] ""',
      "set   \$auth/auth-constraint/role-name/#text '*'",
      'rm      security-constraint/user-data-constraint',
    ],
    require => Staging::Extract['thredds.war'],
    notify  => Tomcat::Service['default'],
  }

}
