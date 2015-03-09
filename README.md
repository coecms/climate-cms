ARCCSS CMS Services
===================

Booting Nodes
-------------

Boot the master server (required before any others)

    ./boot puppet

Boot an agent server and register it with Puppet

    ./boot $NODE
    ssh admin@puppet sudo puppet cert sign $NODE

Retire a server

    ssh admin@puppet sudo puppet node clean $NODE

Servers will be configured with the puppet classes listed in
`hieradata/server/HOSTNAME.yaml`. Generally this will be a list of role
classes, which can be found in the repository under `local/roles/manifests`.

Servers
-------

### proxy

Web proxy server used to control external access

Requres external access on ports 80 and 443 to serve webpages

### puppet

Puppetmaster server used to configure other servers

Requires internal access on port 8140 so agents can receive their
configurations

### code

Code development tools such as Jenkins and Subversion

Requires access from proxy to port 8080 to provide web services

### data

Data management tools such as Thredds and Ramadda

Requires access from to port 8080 to provide web services
