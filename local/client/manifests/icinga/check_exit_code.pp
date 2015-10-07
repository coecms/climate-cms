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

# Check a file for the string 'Exit code: %d' & report if non-zero
define client::icinga::check_exit_code (
  $logfile,
  $timeout        = 120, # Report error if not modified in this many minutes
  $display_name   = undef,
  $vars           = undef,
  $check_interval = undef,
  $retry_interval = undef,
) {
  validate_absolute_path($logfile)
  validate_integer($timeout)

  include client::icinga::plugin::check_exit_code

  client::icinga::check_nrpe {$name:
    display_name     => $display_name,
    nrpe_plugin      => 'check_exit_code',
    nrpe_plugin_args => "-f '${logfile}' -t '${timeout}'",
    check_interval   => $check_interval,
    retry_interval   => $retry_interval,
    vars             => $vars,
  }

}
