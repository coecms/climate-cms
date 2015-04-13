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

# Local type for a monitored cron job
define site::cron (
  $command = $name,
  $user    = undef,
  $hour    = undef,
  $minute  = undef,
  $weekday = undef,
) {
  validate_string($command)

  $status_file = "/tmp/cron-status-${name}"

  $_command = "${command} 2>1 > ${status_file}; echo 'Exit code:' \$? >> ${status_file}"

  ::cron {$name:
    command => $_command,
    user    => $user,
    hour    => $hour,
    minute  => $minute,
    weekday => $weekday,
  }

  client::icinga::check_exit {$name:
    logfile => $status_file,
  }

}