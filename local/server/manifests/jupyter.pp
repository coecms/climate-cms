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
  $url  = '/jupyter',
  $port = '8000', 
  $work = '/var/jupyter',
) {

  include ::git
  include ::anaconda
  include site::nodejs

  $venv = $::anaconda::install_path

  anaconda::pip {'jupyterhub':
  }

  package {'configurable-http-proxy':
    ensure   => present,
    provider => 'npm',
  }

  client::proxy::connection {$url:
    port              => $port,
    allow             => 'from all',
    location_priority => '40',
  }

  client::proxy::connection {"$url/user/test/terminals/websocket":
    type              => 'LocationMatch',
    proxy_path        => "${url}/(user/[^/]*)/(api/kernels/[^/]+/channels|terminals/websocket)(.*)",
    target_path       => "${url}/\$1/\$2\$3",
    protocol          => 'ws',
    port              => $port,
    allow             => 'from all',
    # Must come after proxy for $url in order to override paths
    location_priority => '50',
  }

  user {$user:
    shell  => '/bin/false',
    home   => $work,
    system => true,
  }

  anaconda::pip {'sudospawner':
    package    => 'git+https://github.com/jupyter/sudospawner',
    require    => Class['::git'],
  }

  sudo::conf {'jupyter':
    content => "
      Runas_Alias JUPYTER_USERS = %w35
      Cmnd_Alias  JUPYTER_CMD   = ${venv}/bin/sudospawner
      ${user} ALL=(JUPYTER_USERS) NOPASSWD:JUPYTER_CMD
      "
  }

  # Create home directories for users
  include ::site::pam_mkhomedir

  file {$work:
    ensure => directory,
    owner  => $user,
  }

  file {"${work}/jupyterhub_config.py":
    ensure  => file,
    content => "
c.JupyterHub.base_url = '${url}'
c.JupyterHub.spawner_class = 'sudospawner.SudoSpawner'
c.SudoSpawner.sudospawner_path = '${venv}/bin/sudospawner'
c.Spawner.args = ['--NotebookApp.allow_origin=https://test.climate-cms.org']
    "
  }

  include ::supervisord
  supervisord::program {'jupyterhub':
    command   => "${venv}/bin/jupyterhub",
    user      => $user,
    directory => $work,
    require   => Anaconda::Pip['jupyterhub','sudospawner'],
  }

  File["${work}/jupyterhub_config.py"] ~> Supervisord::Program['jupyterhub']
}
