## \file    site/site/manifests/security.pp
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

class site::security {
  include site::firewall::pre
  include site::firewall::post

  firewallchain {'INPUT:filter:IPv4':
    purge  => true,
    policy => 'accept', # Don't drop ourselves while configuring
    ignore => '-j fail2ban-.*',
  }
  firewallchain {'INPUT:filter:IPv6':
    purge  => true,
    policy => 'accept',
    ignore => '-j fail2ban-.*',
  }
  firewallchain {'FORWARD:filter:IPv4':
    purge  => true,
    policy => 'drop',
  }
  firewallchain {'FORWARD:filter:IPv6':
    purge  => true,
    policy => 'drop',
  }

  class {'::ssh':
    server_options             => {
      'PermitRootLogin'        => 'yes',
      'PasswordAuthentication' => 'no',
      'X11Forwarding'          => 'no',
      'GSSAPIAuthentication'   => 'no',
    }
  }

  class {'::fail2ban':
  }

}
