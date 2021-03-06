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

class site::mail (
  $relay,
) {

  service {'postfix':
    ensure => running,
    enable => true,
  }

  client::icinga::check_process {'postfix':
    command => 'qmgr',
  }

  augeas {'mail server':
    incl    => '/etc/postfix/main.cf',
    lens    => 'Postfix_main.lns',
    context => '/files/etc/postfix/main.cf',
    changes => [
      "set myhostname '${::hostname}.climate-cms.org'",
      "set relayhost  '${relay}'",
    ],
    notify  => Service['postfix'],
  }
}
