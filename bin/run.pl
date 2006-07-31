#!/usr/bin/perl
use strict;
use warnings;

use Sys::Hostname;
use FindBin;

my $force='';
$force=' --force' if $ARGV[0] && $ARGV[0] eq 'force';

my $perl=$^X;
my $hostname=hostname();
my $path=$FindBin::Bin;
my $lib=$path."/../lib";
my ($cpan,$lint,$site);

if ($hostname eq 'libertas') {
    $cpan='/home/ftp/CPAN';
    $lint='/home/domm/Module-CPANTS-Analyse/bin/cpants_lint.pl';
    $site='/home/domm/Module-CPANTS-Site/';

    $ENV{CPANTS_USER}='cpants';
    open(my $fh,'/home/domm/cpants_pwd') || die "Cannot read cpants pwd from /home/domm/cpants_pwd: $!";
    my $pwd=<$fh>;
    close $fh;
    chomp($pwd);
    $ENV{CPANTS_PWD}=$pwd;
    
} else {
    $cpan='/home/minicpan';
    $lint='/home/domm/perl/Module-CPANTS-Analyse/bin/cpants_lint.pl';
    $site='/home/domm/perl/Module-CPANTS-Site/';
}

system("$perl -I$lib $path/analyse_cpan.pl --cpan $cpan --lint $lint $force");
system($perl,"-I$lib", $path."/run_complex_db_stuff.pl",$cpan);
system($perl,"-I$lib", $path."/update_authors.pl",$cpan);
system($perl,"-I$lib", $path."/make_graphs.pl",$site."root/static/");


