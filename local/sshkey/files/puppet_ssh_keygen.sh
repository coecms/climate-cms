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

set -eu

# User name and home directory
TARGET_USER=$1
TARGET_HOME=$(getent passwd $TARGET_USER | cut -f6 -d:)

# Create the user's ssh key
SSH_KEY=$TARGET_HOME/.ssh/id_rsa
if [ ! -f $SSH_KEY ]; then
    sudo -u $TARGET_USER ssh-keygen -N '' -f $SSH_KEY
fi

# Make sure the facts directory exists
FACTS_DIR=/etc/facter/facts.d
if [ ! -d $FACTS_DIR ]; then
    mkdir -p $FACTS_DIR
fi

# Save the key as a fact
PUBLIC_KEY=$(cat ${SSH_KEY}.pub)
cat > ${FACTS_DIR}/${TARGET_USER}_sshkey.txt << EOF
${TARGET_USER}_sshkey=$PUBLIC_KEY
EOF
