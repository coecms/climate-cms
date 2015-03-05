## \file    init.pp
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

class ferret (
  $install_path        = '/usr/local/ferret',
  $install_data        = false,
  $manage_dependencies = false,
) {

  validate_absolute_path($install_path)
  validate_bool($install_data)
  validate_bool($manage_dependencies)

  file {$install_path:
    ensure => directory,
  }

  if $manage_dependencies {
    class {'ferret::dependencies': }
  }

  class {'ferret::install': }
}
