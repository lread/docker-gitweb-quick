#!/bin/sh

# required by gitweb
export GITWEB_CONFIG=/etc/gitweb/gitweb_config.perl

# support for rerouting httpd server access log to stdout
exec 3>&1

# start httpd server in foreground
lighttpd -f /etc/gitweb/lighttpd.conf -D
