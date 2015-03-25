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

# Tells icinga to monitor a process
define client::icinga::check_process (
  $display_name = $name,
  $command      = $name,
  $argument     = undef,
  $user         = $name,
  $warn         = '1:',
  $critical     = '1:',
) {

  @@server::icinga::service {"${::fqdn}-process-${name}":
    service_name     => $name,
    display_name     => $display_name,
    host_name        => $::fqdn,
    check_command    => 'check_nrpe',
    vars             => {
      'nrpe_command' => "process-${name}",
    },
  }

  $_command = "--command='${command}'"

  if $argument {
    $_argument = "--argument-array='${argument}'"
  } else {
    $_argument = ''
  }

  if $user {
    $_user = "--user='${user}'"
  } else {
    $_user = ''
  }

  $_args = "${_command} ${_argument} ${_user}"

  icinga2::nrpe::command {"process-${name}":
    nrpe_plugin_name => 'check_procs',
    nrpe_plugin_args => "-w ${warn} -c ${critical} ${_args}",
  }
}
