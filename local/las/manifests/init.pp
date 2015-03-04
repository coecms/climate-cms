## \file    manifests/init.pp
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

class las (
  $las_title           = 'LAS',
  $proxy_fqdn          = $::fqdn,
  $tomcat_fqdn         = $::fqdn,
  $tomcat_port         = '8080',
  $tomcat_user         = 'tomcat',
  $catalina_home       = '/usr/share/tomcat6',
  $manage_dependencies = false,
) {

  if $manage_dependencies {
    class {'las::dependencies':
      before => Class['las::install'],
    }
    service {'tomcat6':
      ensure    => running,
      subscribe => Class['las::install'],
      require   => Package['tomcat6'],
    }
  }

  class {'las::install': }
}
