## \file    modules/site/manifests/init.pp
#  \author  Scott Wales <scott.wales@unimelb.edu.au>
#
#  Copyright 2014 ARC Centre of Excellence for Climate Systems Science
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

# Generic configuration stuff
class site (
  $hostname    = $::hostname,
  $domain      = $::domain,
  $secure      = false,
  $gdata       = {},
  $users       = {},
  $admins      = {},
  $proxy_ip    = '10.0.0.4',
  $proxy_fqdn  = 'test.climate-cms.org',
  $admin_group = 'fe2_2',
) {
  include ::ntp
  include site::network
  include site::security
  include site::logstash
  include site::mail

  # Don't require a tty for sudoers
  sudo::conf {'requiretty':
    priority => 10,
    content  => 'Defaults !requiretty',
  }

  create_resources('site::user',$users)
  create_resources('site::admin',$admins)

  # Send root mail to admins
  $admin_names = keys($admins)
  mailalias {'root':
    recipient => $admin_names,
  }

  # Allow SSH
  firewall { '022 accept ssh':
    proto  => 'tcp',
    dport  => '22',
    action => 'accept',
  }

  resources {'cron':
    purge => true,
  }

  # Updates
  class {'yum_cron':
    check_only => 'no',
  }

  package {'nfs-utils':}
  file {['/g','/g/data1','/g/data2','/g/data3']:
    ensure => directory,
  }
  create_resources('site::gdata',$gdata)

  # Misc system packages
  @package {[
    'gcc',
  ]:
  }
}
