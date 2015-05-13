Servers
=======

web
---

Apache and Tomcat server. All web requests are proxied through here. Has
``/g/data`` mounted read-only so that data services running under Tomcat can
see it.

puppet-2
--------

Puppet master server. Controls configuration of all other servers using Puppet and Salt

downloader-2
------------

Large storage node for data downloads. Has ``/g/data`` mounted read-write and a
large ``/scratch`` disk to use as a cache

db
--

Postgres database, used by PuppetDB and some data tools

code
----

Jenkins server

metoffice-mirror
----------------

Subversion server that mirrors external repositories at the Met Office

monitor
-------

Icinga and ELK server for monitoring the other hosts
