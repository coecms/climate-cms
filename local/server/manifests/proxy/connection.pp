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

define server::proxy::connection (
  $target_url,
  $path       = $name,
  $order      = undef,
  $allow      = undef,
  $deny       = undef,
  $chain_auth = false,
) {
  include server::proxy

  $vhost = $server::proxy::vhost

  if $chain_auth {
    $_auth_env = 'SetEnv proxy-chain-auth'
  } else {
    $_auth_env = ''
  }

  # Escape slashes
  $escaped_name = regsubst($name, '/', '-', 'G')
  client::icinga::check_nrpe {"https-${escaped_name}":
    display_name     => "https://${vhost}${name}",
    nrpe_plugin      => 'check_http',
    nrpe_plugin_args => "-H '${vhost}' -u '${name}' --ssl -f follow -w 2 -c 10",
  }

  apacheplus::location {$name:
    vhost           => $vhost,
    order           => $order,
    allow           => $allow,
    deny            => $deny,
    custom_fragment => "
      ${_auth_env}
      ProxyPass        ${target_url}
      ProxyPassReverse ${target_url}
    ",
  }

}
