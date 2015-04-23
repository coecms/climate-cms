## \file    local/roles/manifests/elasticsearch.pp
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

class server::elasticsearch (
) {
  include site::java

  class {'::elasticsearch':
    manage_repo  => true,
    repo_version => '1.4',
  }

  ::elasticsearch::instance { 'logstash':
  }

  $logstash_ip = query_nodes('Class[site::logstash]',
                                ipaddress_eth0)

  elasticsearch::firewall {$logstash_ip: }

  $kibana_ip = query_nodes('Class[roles::kibana]',
                                ipaddress_eth0)
  firewall {'920 kibana -> elasticsearch':
    proto  => 'tcp',
    port   => '9200',
    source => $kibana_ip,
    action => 'accept',
  }

  package {'elasticsearch-curator':
    ensure   => present,
    provider => 'pip',
  }

  site::cron {'elasticsearch-curator':
    command => '/usr/bin/curator delete indices --older-than 30 --time-unit days --timestring %Y.%m.%d',
    hour    => 1,
  }
}