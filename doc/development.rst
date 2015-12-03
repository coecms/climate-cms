Development
===========

Adding software
---------------

Check if there's an existing Puppet module to do the work and add it to the
``Puppetfile``. If not create a new module in the ``local/`` directory (or
publish it on Puppet forge)

Create a client and/or server class in their respective directories::

    class server::apache {

Create variables for common parameters (service and user names generally)::

    $service = 'httpd'
    $user    = 'apache'

Call the external module, setting any parameters (prefix class
names from the module with ``::`` to make sure it's using the top-level
versions)::

    class {'::apache':
    }

Add service monitoring using Icinga client types::

    client::icinga::check_process {$service:
       user => $user,
    }

Monitor server logs (TODO):

Backup files::

    client::backup::directory {['/var/www','/etc/httpd']:}

Open firewall ports (using puppetlabs-firewall module)::

    firewall {'080 apache httpd':
       dport  => '80',
       proto  => 'tcp',
       action => 'accept',
    }

If you need to connect to another server in the cloud you can get IPs from
PuppetDB (note the firewall class only accepts 1 IP at a time)::

    $client_ips = query_nodes('Class[client::apache]','ipaddress_eth0')
    firewall {'081 connection from client':
       source => $client_ips[0],
       dport  => '8080',
       proto  => 'tcp',
       action => 'accept',
    }

To connect an address on the proxy server to the service::

    client::proxy::connection {'/apache':
        port  => '8081',
        allow => 'from all',
    }

Backups
-------

The climate-cms cloud uses Amanda (http://www.amanda.org/) for backups. Modules
can request a directory be backed up using::

    client::backup::directory {'/var/www':}

Backups are stored on NCI's `/g/data1` filesystem.

:ref:`recoverBackups`
