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

class server::php {

  include ::php

  # Set timezone
  ::php::config {'php date.timezone':
    file   => '/etc/php.ini',
    config => 'set Date/date.timezone "UTC"',
    notify => Service['httpd'],
  }

  # Database abstraction
  ::php::extension {'pdo':
    ensure  => present,
    package => 'php-pdo',
  }

}
