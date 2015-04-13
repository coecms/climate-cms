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

# Nodes should export this class to have their Puppet agent monitored
define server::puppet::monitor_agent {
  $node = $name

  client::icinga::check {"puppet-agent-${node}":
    display_name     => "${node} puppet agent",
    nrpe_plugin      => 'check_puppetdb_nodes',
    nrpe_plugin_args => "--node='${node}'",
  }
}
