## \file    local/site/manifests/java.pp
#  \author  Scott Wales <scott.wales@unimelb.edu.au>
#
#  Copyright 2015 ARC Centre of Excellence for Climate Systems Science
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

# Wrapper to provide java defaults, can be included by roles
class site::java (
) {
  class {'::java':
  }
  $java_home     = '/usr/lib/jvm/jre'

  include site::ldap

  # Install LDAP cert
  # http://docs.oracle.com/cd/E19509-01/820-3399/ggfrj/index.html
  $keystore  = "${java_home}/lib/security/cacerts"
  $pass      = 'changeit'

  java_ks { 'ldap':
    ensure       => latest,
    certificate  => $site::ldap::ca_file,
    trustcacerts => true,
    target       => $keystore,
    password     => $pass,
    require      => File[$site::ldap::ca_file],
    notify       => Tomcat::Service['default'],
  }
  java_ks { 'apache-self-signed':
    ensure       => latest,
    certificate  => '/etc/pki/tls/certs/localhost.crt',
    trustcacerts => true,
    target       => $keystore,
    password     => $pass,
    require      => Class['apache'],
    notify       => Tomcat::Service['default'],
  }

}
