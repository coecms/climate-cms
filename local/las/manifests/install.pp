## \file    install.pp
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

class las::install {

  $las          = 'las.v8.2'
  $source       = "ftp://ftp.pmel.noaa.gov/ferret/pub/las/${las}.tar.gz"
  $extract_dir  = '/usr/local/las'
  $build_dir    = "${extract_dir}/${las}"

  # Config stuff
  $las_title     = $las::las_title
  $proxy_fqdn    = $las::proxy_fqdn
  $tomcat_fqdn   = $las::tomcat_fqdn
  $tomcat_port   = $las::tomcat_port
  $tomcat_user   = $las::tomcat_user
  $catalina_home = $las::catalina_home
  $ferret_dir    = $::ferret::install_path

  file {[$extract_dir,$build_dir]:
    ensure => directory,
  }

  file {"${build_dir}/answers":
    ensure  => file,
    content => template('las/answers.erb'),
    notify  => Exec['build-las'],
  }

  staging::deploy {'las.tar.gz':
    target  => $extract_dir,
    source  => $source,
    creates => "${build_dir}/configure",
  }

  exec {'build-las':
    command     => "${build_dir}/configure < ${build_dir}/answers",
    cwd         => $build_dir,
    environment => "FER_DIR=${ferret_dir}",
    require     => [
      Staging::Extract['las.tar.gz'],
      Class['ferret'],
      Package['ant'],
    ],
    creates     => "${catalina_home}/webapps/las.war",
  }

  file {"${catalina_home}/content/las/logs":
    owner   => $tomcat_user,
    require => Exec['build-las'],
  }
}
