## Copyright 2016 ARC Centre of Excellence for Climate Systems Science
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

define anaconda::pip (
  $ensure  = 'installed',
  $package = $name,
) {
  include ::anaconda

  $pip = "${::anaconda::bin}/pip"
  $conda = "${::anaconda::bin}/conda"
  $_version = ''

  exec {"anaconda pip install ${name}":
    command => "${pip} install ${_version} ${package}",
    unless  => "${conda} list | /bin/grep -w '^${name}'",
    require => Class['::anaconda::install'],
  }

}
