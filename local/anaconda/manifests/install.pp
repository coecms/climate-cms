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

class anaconda::install {
  include ::anaconda
  
  $installer    = '/tmp/anaconda-installer.sh'
  $source_url   = 'https://repo.continuum.io/archive/Anaconda3-2.4.1-Linux-x86_64.sh'
  $checksum     = '45249376f914fdc9fd920ff419a62263'

  user {$::anaconda::user:
    shell  => '/bin/false',
    home   => $install_path,
    system => true,
  }

  exec {'Download anaconda':
    command => "/usr/bin/curl '${source_url}' -o '${installer}'",
    creates => $installer,
  }

  file {$installer:
    subscribe => Exec['Download anaconda'],
  }

  file {$anaconda::install_path:
    ensure => directory,
  }

  exec {'Install anaconda':
    command   => "echo '${checksum}  ${installer}' | md5sum -c && /bin/bash '${installer}' -b -p '${::anaconda::install_path}'",
    user      => $::anaconda::user,
    creates   => "${::anaconda::bin}/conda",
    require   => File[$anaconda::install_path],
    subscribe => File[$installer],
  }

}
