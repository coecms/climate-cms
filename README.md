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

Puppet Modules
--------------

Local Puppet modules are found in the `local` directory. There are three main
directories there that will be of interest.

 * *site*: Generic site configuration
 * *client*: Client software, generally installed on all nodes so that they can
             access a server
 * *server*: Server software, generally installed on a single node

Classes are assigned to nodes using Hiera. Classes listed in `common.yaml` will
be assigned to all nodes, classes listed in `server/$HOSTNAME.yaml` will be
assigned to that host.

Servers
-------

### web

Web proxy server used to control external access. Also has tomcat-based data tools

Requres external firewall access on ports 80 and 443 to serve webpages

### puppet

Puppetmaster server used to configure other servers

### code

Code development tools such as Jenkins and Subversion

### monitor

Monitoring software such as Icinga and Kibana

### db

Postgres database server
