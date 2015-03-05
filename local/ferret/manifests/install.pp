## \file    install.pp
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

class ferret::install (
) {
  $install_path = $ferret::install_path

  $os = 'rhel6_64'

  $server       = 'ftp://ftp.pmel.noaa.gov/ferret/pub'
  $execs        = "${server}/${os}/fer_executables.tar.gz"
  $environment  = "${server}/${os}/fer_environment.tar.gz"
  $datasets     = "${server}/data/fer_dsets.tar.gz"

  staging::deploy {'fer_executables.tar.gz':
    source  => $execs,
    target  => $install_path,
    creates => "${install_path}/bin/ferret",
    require => File[$install_path],
  }
  staging::deploy {'fer_environment.tar.gz':
    source  => $environment,
    target  => $install_path,
    creates => "${install_path}/contrib",
    require => File[$install_path],
  }

  if $ferret::install_data {
    staging::deploy {'fer_dsets.tar.gz':
      source  => $datasets,
      target  => $install_path,
      creates => "${install_path}/data",
      require => File[$install_path],
    }
  }

}
