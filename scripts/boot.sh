#!/bin/bash
## \file    scripts/boot.sh
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

image='centos-6.5-20140715'
flavor='m1.small'
branch='master'

nova boot "svn.accessdev.nci.org.au" \
    --image="$image" \
    --flavor="$flavor" \
    --poll \
    --user-data <( cat <<EOF
#user-data
disable_root:     true
manage_etc_hosts: localhost

hostname: svn
fqdn:     svn.accessdev.nci.org.au

runcmd:
    - rpm -i http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm
    - yum -y install git puppet
    - git clone -b ${branch} https://github.com/ScottWales/svnmirror /etc/puppet/environments/production
    - puppet apply /etc/puppet/environments/production/manifests/site.pp

EOF
)

