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

class server::puppet::reports {
  $report_port = 5959

  augeas { 'reports':
    lens    => 'Puppet.lns',
    incl    => '/etc/puppet/puppet.conf',
    changes => 'set master/reports "logstash"',
    require => File['/etc/puppet/puppet.conf'],
    notify  => Service['puppetserver'],
  }

  class {'logstash_reporter':
    logstash_port => $report_port,
  }

  logstash::configfile {'input puppetserver':
    content => "
    input {
      tcp {
        type   => \"puppet-report\"
        port   => \"${report_port}\"
        format => \"json_event\"
      }
    }
    \n",
    order   => 15,
  }

}
