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

class server::kibana {

  $package    = 'kibana-4.1.0-linux-x64'
  $source_url = "https://download.elasticsearch.org/kibana/kibana/${package}.tar.gz"

  $elasticsearch = query_nodes('Class[server::elasticsearch]',
                                ipaddress_eth0)

  class {'supervisord': }

  file {'/opt/kibana':
    ensure => directory,
  }

  user {'kibana':
    shell  => '/sbin/nologin',
    home   => '/opt/kibana',
    system => true,
  }

  staging::file {"${package}.tar.gz":
    source => $source_url,
  } ->
  staging::extract {"${package}.tar.gz":
    target  => '/opt/kibana',
    creates => '/opt/kibana/bin/kibana',
    strip   => 1,
    notify  => File['kibana.yml'],
  }

  augeas {'set kibana elasticsearch host':
    incl    => '/opt/kibana/config/kibana.yml',
    lens    => 'Cobblersettings.lns',
    context => '/files/opt/kibana/config/kibana.yml',
    changes => "set elasticsearch_url '\"http://${elasticsearch}:9200\"'",
    require => Staging::Extract["${package}.tar.gz"],
    notify  => File['kibana.yml'],
  }

  # Restart on config change
  file {'kibana.yml':
    path    => '/opt/kibana/config/kibana.yml',
    notify  => Supervisord::Supervisorctl['restart_kibana'],
  }
  supervisord::supervisorctl {'restart_kibana':
    command     => 'restart',
    process     => 'kibana',
    refreshonly => true,
    require     => Supervisord::Program['kibana'],
  }

  supervisord::program {'kibana':
    command => '/opt/kibana/bin/kibana',
    user    => 'kibana',
    require => [User['kibana'],File['kibana.yml']],
  }

  client::proxy::connection {'/admin/kibana':
    target_path => '',
    port        => '5601',
  }
}
