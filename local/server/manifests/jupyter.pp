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

class server::jupyter (
  $user = 'jupyter',
  $port = '8000', 
) {

  include ::python
  include site::nodejs

  realize Package['gcc']

  $venv = '/opt/jupyter'
  
  python::virtualenv {$venv:
  }

  package {'zeromq3-devel':
  }
  python::pip {'pyzmq':
    virtualenv => $venv,
    require    => Package['gcc','zeromq3-devel'],
  }

  python::pip {'jupyterhub':
    virtualenv => $venv,
    require    => Python::Pip['pyzmq'],
  }

  package {'configurable-http-proxy':
    ensure   => present,
    provider => 'npm',
  }

  client::proxy::connection {'/jupyter':
    port  => $port,
    allow => 'from all',
  }

  user {$user:
    shell  => '/bin/false',
    system => true,
  }

  python::pip {'sudospawner':
    virtualenv => $venv,
    url        => 'git+https://github.com/jupyter/sudospawner',
  }

  # Wrapper to enable the SCL variables
  file {"${venv}/bin/sudospawner-scl":
    ensure  => file,
    mode    => '0755',
    content => "#!/bin/bash
      scl enable '${::python::scl}' \"${venv}/bin/sudospawner $*\"
    "
  }

  sudo::conf {'jupyter':
    content => "
      Runas_Alias JUPYTER_USERS = saw562
      Cmnd_Alias  JUPYTER_CMD   = ${venv}/bin/sudospawner-scl
      ${user} ALL=JUPYTER_USERS NOPASS:JUPYTER_CMD
      "
  }
}
