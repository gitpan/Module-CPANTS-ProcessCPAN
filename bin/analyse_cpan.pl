#!/usr/bin/perl
use strict;
use warnings;
use Module::CPANTS::ProcessCPAN;

die "Usage: analyse_cpan.pl path/to/minicpan path/to/cpants_lint.pl" unless @ARGV ==2;
my $path_cpan=shift(@ARGV);
my $path_lint=shift(@ARGV) || 'cpants_lint.pl';
die "Cannot find cpants_lint.pl (in $path_lint)" unless -e $path_lint;

my $p=Module::CPANTS::ProcessCPAN->new($path_cpan,$path_lint);
$p->lint($path_lint);
$p->start_run->process_cpan;


