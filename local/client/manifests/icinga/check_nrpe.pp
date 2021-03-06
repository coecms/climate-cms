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

# Run a check on this host using nrpe
define client::icinga::check_nrpe (
  $display_name      = $name,
  $nrpe_command_name = $name,
  $nrpe_plugin       = undef,
  $nrpe_plugin_args  = '',
  $vars              = {},
  $check_interval    = undef,
  $retry_interval    = undef,
) {
  # Ensure no white-space for filenames
  validate_re($name,'^\S+$')
  validate_re($nrpe_command_name, '^\S+$')

  $nrpe_vars = {
      'nrpe_command' => $nrpe_command_name,
      'nrpe_plugin'  => $nrpe_plugin,
  }
  $_vars = merge($nrpe_vars, $vars)

  @@server::icinga::service {"${::fqdn}-${name}":
    service_name   => $name,
    display_name   => $display_name,
    host           => $::fqdn,
    check_command  => 'check_nrpe',
    check_vars     => $_vars,
    check_interval => $check_interval,
    retry_interval => $retry_interval,
  }

 ::nrpe::command {$nrpe_command_name:
   ensure  => present,
   command => "${nrpe_plugin} ${nrpe_plugin_args}",
 }
}
