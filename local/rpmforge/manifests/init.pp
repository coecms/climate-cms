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

class rpmforge {
  if $::osfamily == 'RedHat' {

    $pubkey_path = '/tmp/rpmforge.key'

    file {$pubkey_path:
      ensure => file,
      source => "puppet:///modules/rpmforge/RPM-GPG-KEY.dag.txt",
    }
    
    exec {'Import RpmForge Key':
      command => "/bin/rpm --import ${pubkey_path}",
      creates => '/etc/pki/rpm-gpg/RPM-GPG-KEY-rpmforge-dag',
      require => File[$pubkey_path],
    }

    $version = '0.5.3-1'
    $maj     = $::operatingsystemmajrelease
    $arch    = $::architecture
    $rpm     = "rpmforge-release-${version}.el${maj}.rf.${arch}"

    package {'rpmforge':
      provider => 'rpm',
      name     => $rpm,
      source   => "http://pkgs.repoforge.org/rpmforge-release/${rpm}.rpm",
      require  => Exec['Import RpmForge Key'],
    }

  }
}
