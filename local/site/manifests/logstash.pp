## \file    local/site/manifests/logstash.pp
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

# Install logstash for monitoring
class site::logstash (
) {
  include site::java

  $elasticsearch_ip = query_nodes('Class[roles::elasticsearch]',
                                ipaddress_eth0)

  class {'::logstash':
    install_contrib => true,
    manage_repo     => true,
    repo_version    => '1.4',
  }

  # Collect generic system resource usage
  class {'::collectd':
    purge        => true,
    recurse      => true,
    purge_config => true,
  }

  include ::collectd::plugin::cpu
  include ::collectd::plugin::df
  include ::collectd::plugin::interface
  include ::collectd::plugin::load
  include ::collectd::plugin::memory
  include ::collectd::plugin::disk

  # Send stats to logstash
  collectd::plugin::network::server {$::hostname:
    port => 25826,
  }

  logstash::configfile {'input collectd':
    content => "input {collectd{}}\n",
    order   => '10',
  }
  logstash::configfile {'output elasticsearch':
    content => "output {elasticsearch{host => '${elasticsearch_ip}'}}\n",
    order   => '90',
  }

  # Bidirectional comms required for logstash
  firewall {"931 elasticsearch to ${elasticsearch_ip}":
    proto  => 'tcp',
    port   => '9300-9305',
    source => $elasticsearch_ip,
    action => 'accept',
  }

}
