#!/bin/bash
#  Copyright 2015 ARC Centre of Excellence for Climate Systems Science
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

# Sets up encryption keys for Amanda backup system
# see 'man amcrypt'

set -eu

PASSPHRASE=$(pwgen 40)

mkdir -p ~/.gnupg
chmod 0700 ~/.gnupg
head -c 2925 /dev/random | uuencode -m - | head -n 66 | tail -n 65 \ | gpg --symmetric --passphrase "$PASSPHRASE" -a > ~/.gnupg/am_key.gpg

echo $PASSPHRASE > ~/.am_passphrase
chmod 0700 ~/.am_passphrase
