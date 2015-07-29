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

class ncl (
  $path = '/opt/ncl',
) {

  $source = 'https://www.earthsystemgrid.org/download/fileDownload.htm?logicalFileId=e0866847-cd9a-11e4-bb80-00c0f03d5b7c'

  file {$path:
    ensure => directory,
  }

  staging::deploy { 'ncl.tar.gz':
    source => $source,
    target => $path,
  }
}
