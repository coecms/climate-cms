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

class server::puppet::ca {
  $private_path = $server::puppet::private_path

  # Certificate stuff for MCollective
  # Users who need access to mcollective should put their certificates in
  # ${private_path}/mcollective/certs. By default the 'mcollective' user is
  # certified to use mco.

  # Generate shared host keys
  include client::puppet
  exec {'puppet cert generate mcollective-shared':
    path    => '/usr/bin',
    creates => "${client::puppet::certdir}/mcollective-shared.pem",
  }
  exec {'puppet cert generate mcollective-user':
    path    => '/usr/bin',
    creates => "${client::puppet::certdir}/mcollective-user.pem",
  }
  file {[
    "${private_path}/mcollective",
    "${private_path}/mcollective/certs",
    "${private_path}/mcollective/keys"]:
    ensure  => directory,
    owner   => 'puppet',
    group   => 'puppet',
    mode    => '0700',
    purge   => true,
    recurse => true,
  }
  file {"${private_path}/mcollective/clients":
    ensure  => directory,
  }
  file {"${private_path}/mcollective/certs/mcollective-shared.pem":
    ensure    => file,
    show_diff => false,
    source    => "file://${client::puppet::certdir}/mcollective-shared.pem",
    require   => Exec['puppet cert generate mcollective-shared'],
  }
  file {"${private_path}/mcollective/certs/mcollective-user.pem":
    ensure    => file,
    show_diff => false,
    source    => "file://${client::puppet::certdir}/mcollective-user.pem",
    require   => Exec['puppet cert generate mcollective-user'],
  }
  file {"${private_path}/mcollective/keys/mcollective-shared.pem":
    ensure    => file,
    show_diff => false,
    source    => "file://${client::puppet::privatekeydir}/mcollective-shared.pem",
    require   => Exec['puppet cert generate mcollective-shared'],
  }
  file {"${private_path}/mcollective/keys/mcollective-user.pem":
    ensure    => file,
    show_diff => false,
    source    => "file://${client::puppet::privatekeydir}/mcollective-user.pem",
    require   => Exec['puppet cert generate mcollective-user'],
  }
  file {"${private_path}/mcollective/clients/mcollective.pem":
    ensure    => file,
    show_diff => false,
    source    => "file://${client::puppet::certdir}/mcollective-user.pem",
    require   => Exec['puppet cert generate mcollective-user'],
  }

}
