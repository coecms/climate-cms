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

define scl::exec (
  $scl,
  $command = undef,
  $path    = undef,
  $user    = undef,
  $creates = undef,
  $onlyif  = undef,
  $unless  = undef,
) {

  $root = "/opt/rh/${scl}/root"
  $librarypath = "LD_LIBRARY_PATH=${root}/usr/lib64"

  $apath   = any2array($path)
  $sclpath = concat($apath, "${root}/usr/bin")
 
  exec {$name:
    command     => $command,
    creates     => $creates,
    onlyif      => $onlyif,
    unless      => $unless,
    path        => $sclpath,
    environment => $librarypath,
    user        => $user,
  }
}
