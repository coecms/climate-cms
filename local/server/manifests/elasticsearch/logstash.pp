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

class server::elasticsearch::logstash {
  include server::elasticsearch

  ::elasticsearch::instance { 'logstash':
    config => {
      'indices.fielddata.cache.size' => '1gb',
    },
  }

  $logstash_ip = query_nodes('Class[site::logstash]',
                                ipaddress_eth0)

  ::server::elasticsearch::firewall {$logstash_ip: }

  $kibana_ip = query_nodes('Class[roles::kibana]',
                                ipaddress_eth0)
  firewall {'920 kibana -> elasticsearch':
    proto  => 'tcp',
    dport  => '9200',
    source => $kibana_ip,
    action => 'accept',
  }

  package {'elasticsearch-curator':
    ensure   => present,
    provider => 'pip',
  }

  site::cron {'elasticsearch-curator':
    command => '/usr/bin/curator delete indices --older-than 30 --time-unit days --timestring \'\%Y.\%m.\%d\'',
    hour    => 1,
    minute  => 0,
  }
  site::cron {'elasticsearch-optimise':
    command => '/usr/bin/curator optimize indices --older-than 2 --time-unit days --timestring \'\%Y.\%m.\%d\'',
    hour    => 1,
    minute  => 10,
  }
}
