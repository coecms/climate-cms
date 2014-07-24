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

envpath='/etc/puppet/environments'

nova boot "svn.accessdev.nci.org.au" \
    --image="$image" \
    --flavor="$flavor" \
    --security-groups "ssh,http" \
    --poll \
    --user-data <( cat <<EOF
#cloud-config
disable_root:     true
manage_etc_hosts: localhost

hostname:         svn
fqdn:             svn.accessdev.nci.org.au

ssh_authorized_keys:
    - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCpsHvduCAb+GmoxaE/b3OMYtLbUaGVvNvPULPkfpGzPxhKjAwJHmO2Xv3dgfvdzeFZdltGHSfAd87e+OULcXV+ZeMRp/wy/SCCM4wJdUfa7i7IGzaoaseZDYojcANqXUzqnoEvsG1gHIE8FhweUiM6RK/7mG3n0KwRqtwdz86lI5pY0Y5vxz60xObo5m2oMC+zARLVtqg7KLaajp4zX7vwgBofbhupwy+oruXRXJkJh4gE31huIC68LzS6xWOfOvDc2KsIuh1BqmlxlNnrR7VsPL/VP057/37Z31OOZRA0zlQhhOZhrsmnzst04gGy5uymtw6ougGghodMZsXG9c5N scottwales@mu00053329

runcmd:
    - [/bin/bash, '-c', 'echo -e "Defaults:ec2-user !requiretty\nec2-user ALL=NOPASSWD:ALL" > /etc/sudoers.d/ec2-user']
    - rpm -i http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm
    - yum -y install git puppet
    - git clone -b ${branch} https://github.com/ScottWales/svnmirror $envpath/production
    - ln -s /etc/puppet/{environments/production/,}hiera.yaml
    - bash $envpath/production/modules/site/files/provison.sh

EOF
)

