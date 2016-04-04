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

class server::jenkins (
  $path = '/jenkins',
  $port = 8009,
) {
  include site::java
  include site::ldap
  include ::git

  package { 'puppet-lint':
    ensure   => '1.1.0',
    provider => 'gem',
  }

  class {'::jenkins':
    config_hash        => {
      'JENKINS_ARGS'   => {'value' => "--prefix=${path}"},
      'AJP_PORT'       => {'value' => "${port}"},
      'HTTP_PORT'      => {'value' => '8080'},},
    install_java       => false,
    configure_firewall => false,
    require            => Class['java'],
  }

  client::proxy::connection {$path:
    allow                 => 'from all',
    protocol              => 'ajp',
    port                  => $port,
    nocanon               => true,
    allow_encoded_slashes => 'NoDecode',
  }

  firewall {'401 jenkins from climate-cms.nci.org.au':
    dport  => 8080,
    proto  => 'tcp',
    source => '10.0.0.68',
    action => 'accept',
  }

  client::icinga::check_process {'jenkins':
    command  => 'java',
    argument => '-jar /usr/lib/jenkins/jenkins.war',
    user     => 'jenkins',
  }

  scl {'git19':
  }
}
