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

define server::icinga::service (
  $service_name,
  $host_name,
  $check_command,
  $vars,
  $display_name = $name,
) {

  @icinga2::object::servicegroup {$service_name:
    display_name => $display_name,
  }

  realize Icinga2::Object::Servicegroup[$service_name]

  icinga2::object::service {$name:
    display_name  => $display_name,
    host_name     => $host_name,
    groups        => [$service_name],
    check_command => $check_command,
    vars          => $vars,
  }

}


