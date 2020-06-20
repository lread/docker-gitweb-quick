#!/usr/bin/perl

# This file is based on one generated to ./.git/gitweb/gitweb_config.perl by: git instaweb

our $projectroot = "/repo";
our $git_temp = "/tmp";
our $projects_list = $projectroot;

push @stylesheets, "static/highlight.css";

$feature{'highlight'}{'default'} = [1];

# NOTE: gitweb highlight config will automatically be concatenated after this line for docker image
