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
  $path                  = $name,
  $type                  = undef,
  $order                 = undef,
  $allow                 = undef,
  $deny                  = undef,
  $chain_auth            = false,
  $check_auth            = false,
  $location_priority     = undef,

  $nocanon               = false,
  $allow_encoded_slashes = undef,
) {
  include server::proxy

  $vhost = $server::proxy::vhost

  if $chain_auth {
    $_auth_env = 'SetEnv proxy-chain-auth'
  } else {
    $_auth_env = ''
  }

  if $check_auth {
    $expect = '--expect=401'
  } else {
    $expect = ''
  }

  validate_bool($nocanon)
  if $nocanon == true {
    $_nocanon = ' nocanon'
  } else {
    $_nocanon = ''
  }

  if $allow_encoded_slashes {
    $_allowslash = "AllowEncodedSlashes ${allow_encoded_slashes}"
  }

  # Escape slashes
  $escaped_name = regsubst($name, '/', '-', 'G')
  client::icinga::check_nrpe {"https-${escaped_name}":
    display_name     => "https://${vhost}${name}",
    nrpe_plugin      => 'check_http',
    nrpe_plugin_args => "-H '${vhost}' -u '${name}' --ssl -f follow -w 2 -c 10 ${expect}",
  }

  apacheplus::location {$path:
    vhost             => $vhost,
    type              => $type,
    order             => $order,
    allow             => $allow,
    deny              => $deny,
    location_priority => $location_priority,
    custom_fragment   => "
      ${_auth_env}
      ProxyPass        ${target_url}${_nocanon}
      ProxyPassReverse ${target_url}
      ${_allowslash}
    ",
  }

}
