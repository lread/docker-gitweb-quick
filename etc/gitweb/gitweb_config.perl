#!/usr/bin/perl

# This file is based on one generated to ./.git/gitweb/gitweb_config.perl by: git instaweb

our $projectroot = "/repo";
our $git_temp = "/tmp";
our $projects_list = $projectroot;

$feature{'highlight'}{'default'} = [1];

# gitweb defaults to a very small subset of what is offered by the highlight program,
# enable some formats of interest here:

our %highlight_basename;
$highlight_basename{'Dockerfile'} = 'dockerfile';

our %highlight_ext;
$highlight_ext{'clj'} = 'clojure';
$highlight_ext{'cljs'} = 'clojure';
$highlight_ext{'cljc'} = 'clojure';
$highlight_ext{'edn'} = 'clojure';

$highlight_ext{'md'} = 'markdown';
$highlight_ext{'adoc'} = 'AsciiDoc';

$highlight_ext{'go'} = 'go';

$highlight_ext{'bat'} = 'cmd';

$highlight_ext{'docker'} = 'dockerfile';
