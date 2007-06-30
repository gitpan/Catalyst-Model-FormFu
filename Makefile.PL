use strict;
use inc::Module::Install;

name 'Catalyst-Model-FormFu';
all_from 'lib/Catalyst/Model/FormFu.pm';

requires 'Best';
requires 'Catalyst';
requires 'Config::Any';
requires 'Data::Dumper';
requires 'Data::Visitor::Callback';
requires 'Digest::MD5';
requires 'HTML-FormFu';

auto_install;
WriteAll(meta => 1);

