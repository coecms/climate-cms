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

# Site defaults for mcollective
class site::mcollective (
) {
  # Get middleware host from puppetdb
  $middleware_hosts = query_nodes('Class[mcollective]{middleware=true}',
                                  hostname)

  class {'::activemq':
    # See https://github.com/puppetlabs/puppetlabs-activemq/pull/31
    version => '5.9.1-2.el6',
  }
  class {'::mcollective':
    middleware_hosts => $middleware_hosts,
    require          => Class['::activemq'],
  }

}
