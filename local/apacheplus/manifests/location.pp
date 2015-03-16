## \file    modules/apacheplus/manifests/location.pp
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

define apacheplus::location (
  $vhost,
  $vhost_priority    = '25',
  $location_priority = '25',
  $location          = $name,
  $order             = 'Deny,Allow',
  $allow             = 'from none',
  $deny              = 'from all',
  $auth_name         = $site::hostname,
  $ldap_require      = undef,
  $custom_fragment   = '',
  $template          = 'apacheplus/location.erb',
) {

  if $ldap_require {
    include ::site::ldap
    include ::apache::mod::auth_basic
    include ::apache::mod::authnz_ldap

    $ldap_url = "${site::ldap::url}/${site::ldap::user_dn}?${site::ldap::user_id}"
    $ldap_group_member = $site::ldap::group_member
  }

  concat::fragment { $name:
    target  => "${vhost_priority}-${vhost}.conf",
    order   => $location_priority,
    content => template($template),
  }

}

