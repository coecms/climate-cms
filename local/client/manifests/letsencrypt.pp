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

class client::letsencrypt {

  include ::git

  $user = 'letsencrypt'
  $domain = 'test.climate-cms.org'

  user {$user:
    gid => 'apache',
  }

  $install_path = '/opt/letsencrypt'
  vcsrepo { $install_path:
    ensure   => present,
    provider => git,
    source   => 'https://github.com/diafygi/acme-tiny',
    revision => '3f68f50f347f957cef8425a41989e6c255b37f32',
  }

  $keypath = '/var/lib/letsencrypt'
  file {$keypath:
    ensure => directory,
    owner  => $user,
    group  => 'apache',
    mode   => '0750',
  }

  # Create a key for the account
  exec {'letsencrypt account key':
    command => "/usr/bin/openssl genrsa -out ${keypath}/account.keyi 4096",
    creates => "${keypath}/account.key",
    require => File[$keypath],
  }
  file {"${keypath}/account.key":
    owner   => 'root',
    group   => 'apache',
    mode    => '0640',
    require => Exec['letsencrypt account key']
  }

  # Create a public key for $domain
  exec {"letsencrypt key ${domain}":
    command => "/usr/bin/openssl genrsa -out ${keypath}/${domain}.key 4096",
    creates => "${keypath}/${domain}.key",
    require => File[$keypath],
  }
  file {"${keypath}/${domain}.key":
    owner   => 'apache',
    group   => 'root',
    mode    => '0600',
    require => Exec["letsencrypt key ${domain}"]
  }

  # Create a request for $domain
  exec {"letsencrypt csr ${domain}":
    command => "/usr/bin/openssl req -new -sha256 -key ${keypath}/${domain}.key -subj '/CN=${domain}' -out ${keypath}/${domain}.csr",
    creates => "${keypath}/${domain}.csr",
    require => File["${keypath}/${domain}.key"]
  }
  file {"${keypath}/${domain}.csr":
    owner   => 'apache',
    group   => 'apache',
    mode    => '0440',
    require => Exec["letsencrypt csr ${domain}"]
  }

  # Serve challange responses here
  $challengepath = "/var/www/acme-challanges"
  file {$challengepath:
    ensure => directory,
    owner  => $user,
    group  => 'apache',
    mode   => '0750',
  }

  apacheplus::location {$challengepath:
    vhost           => $domain,
    type            => 'Directory',
    order           => 90,
    allow           => 'from all',
    deny            => 'from none',
  }
  apacheplus::alias {'/.well-known/acme-challenge':
    vhost  => $domain,
    target => $challengepath,
  }

  #  # Sign the request
  #  exec {"letsencrypt sign ${domain}":
  #    command => "python '${install_path}/acme_tiny.py' --account_key '${keypath}/account.key' --csr '${keypath}/${domain}.csr' --acme-dir '${challangepath}' > '${keypath}/${domain}.crt'"
  #    user    => $user,
  #    path    => '/usr/bin'
  #    creates => "${keypath}/${domain}.crt"
  #  }
  #  file {"${keypath}/${domain}.crt":
  #    owner => $user,
  #    group => 'apache',
  #    mode  => '640',
  #  }
}
