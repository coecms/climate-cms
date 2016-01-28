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

class server::apache {

  # Use apache24 from SCL
  $scl     = 'httpd24'
  $package = "${scl}-httpd"
  $service = $package

  scl {$scl:}
  scl::package {[
    'mod_ldap',
    'mod_ssl',
  ]:
    scl => $scl,
  }

  # Override paths to use the SCL
  $etc_dir   = "/opt/rh/${scl}/root/etc/httpd"
  $conf_dir  = "${etc_dir}/conf"
  $confd_dir = "${etc_dir}/conf.d"

  file {'/var/www':
    ensure => directory,
  }

  class {'::apache':
    default_vhost  => false,
    default_mods   => false,
    apache_version => '2.4',
    apache_name    => $package,
    service_name   => $service,
    httpd_dir      => $etc_dir,
    server_root    => $etc_dir,
    conf_dir       => $conf_dir,
    mod_dir        => $confd_dir,
    confd_dir      => $confd_dir,
    vhost_dir      => $confd_dir,
    ports_file     => "${conf_dir}/ports.conf",
  }

  client::icinga::check_process {$service:
    display_name => 'apache',
    user         => 'apache',
  }

}
