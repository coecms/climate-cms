Admin Tasks
===========

Add a new admin
---------------

Edit the file ``hireadata/admins.yaml``, adding the new admin's username and
public ssh key. Commit the changes and :ref:`updatePuppet`.

SSH to a Server
---------------

Not all servers in the cloud have public IPs. To connect to an arbitrary server
go through the gateway first::

    ssh -A climate-cms.org
    ssh monitor

.. _updatePuppet:

Update Puppet
-------------

First connect to the Puppet server::

    ssh -A climate-cms.org
    ssh puppet-2

Shut down any running Puppet agent instances::

    sudo salt '*' service.stop puppet

Pull updates from Github and update modules::

    sudo r10k deploy environment --puppetfile

Do a dry run to make sure changes are doing what you expect::

    sudo salt '*' puppet.noop agent test

Finally apply the changes and restart the Puppet agents (``test`` here
means print changes and don't run in the background)::

    sudo salt '*' puppet.run agent test
    sudo salt '*' service.start puppet

You can also apply changes to a specific server by replacing the ``'*'`` with a
hostname.

.. _recoverBackups:

Recover Backups
---------------

The ``amrecover`` tool is used to recover backups. Full instructions can be
found on the `Amanda wiki
<http://wiki.zmanda.com/index.php/GSWA/Recovering_Files>`_.

``amrecover`` must be run as root on the 'downloader' VM, which is where
backups are stored.

Create an empty directory to put the recovered files in, then start a recovery from
the daily backups::

    mkdir recover
    cd recover
    sudo amrecover daily

This will start a console session for data recovery. Some useful commands are:

 * ``listhost``: List all hosts
 * ``sethost HOST``: Set the host to restore
 * ``listdisk``: List backup areas (e.g. ``/home``, ``/etc``)
 * ``setdisk DISK``: Set the area to restore
 * ``history``: List backup dates
 * ``setdate DATE``: Set the date to recover
 * ``ls``, ``cd``, etc.: Move around the backed-up data
 * ``add FILE``: Add a file to the restore list
 * ``extract``: Extract all files in the restore list

The files will be placed in the directory you ran ``amrecover`` from. You can
then move them into the appropriate place.

The backup data files are stored on the ``/scratch`` filesystem, and mirrored
to permanent storage in ``/g/data1/ua8/climate-cms-backups`` in an encrypted
format. Scott has external backups of the encryption keys in case they are
lost.
