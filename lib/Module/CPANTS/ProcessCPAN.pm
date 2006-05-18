package Module::CPANTS::ProcessCPAN;
use strict;
use warnings;

use Module::CPANTS::Analyse;
use Module::CPANTS::DB;
use Module::CPANTS::Kwalitee;
use Data::Dumper;
use base qw(Class::Accessor);
use Carp;
use File::Spec::Functions qw(catdir catfile rel2abs);
use Parse::CPAN::Packages;

use vars qw($VERSION);
$VERSION=0.60;

__PACKAGE__->mk_accessors(qw(cpan lint run _db));

sub new {
    my ($class,$cpan,$lint)=@_;

    croak "Cannot find root of local CPAN mirror (location $cpan)" unless -d $cpan;

    my $self=bless {},$class;
    $self->cpan(rel2abs($cpan));
    unless ($lint) {
        $lint=`which cpants_lint.pl`;
        chomp($lint);
        die "Cannot find cpants_lint.pl" unless $lint;
    }
    $self->lint(rel2abs($lint));
    return $self;
}

sub start_run {
    my $self=shift;

    my $mck=Module::CPANTS::Kwalitee->new;
    my $total_kwalitee=scalar @{$mck->get_indicators};
    
    my $run=$self->db->resultset('Run')->create({
        version=>$Module::CPANTS::Analyse::VERSION,
        date=>scalar localtime,
        available_kwalitee=>$total_kwalitee,
    });
    $self->run($run);
    return $self;
}


sub process_cpan {
    my $self=shift;
    
    my $p=Parse::CPAN::Packages->new($self->cpan_02packages);
    my $db=$self->db;
    my $lint=$self->lint;
    
    foreach my $dist (sort {$a->dist cmp $b->dist} $p->latest_distributions) {
        my $vname=$dist->distvname;
        
        my @exists=$db->resultset('Dist')->search(dist=>$dist->dist);
        if (@exists > 0) {
            # check version
            if ($exists[0]->vname && $vname eq $exists[0]->vname) {
                print "skip ".$dist->dist." (".($dist->version || '?').")\n";
                next;
            } else {
                print "new version of ".($dist->dist || '?')." (".$exists[0]->version." -> ".($dist->version || '?')." )\n";
                $exists[0]->delete;
            }
        }
        
        next if $vname=~/^perl[-\d]/;
        next if $vname=~/^ponie-/;
        next if $vname=~/^Perl6-Pugs/;
        next if $vname=~/^parrot-/;
        next if $vname=~/^Bundle-/;
        
        print "analyse $vname\n";
       
        # todo: store immediatly in DB so we can catch "bad" dists that fail
        # completely
        
        my $file=$self->cpan_path_to_dist($dist->prefix);
        
        # call cpants_lint.pl (fork because I think it's easier)
        my $lintresult=`$^X $lint -d $file`;
        my $data;
        eval {
            my $VAR1;
            eval $lintresult;
            $data=$VAR1;
        };
        
        # remove data that references other tables;
        my $kwalitee=$data->{kwalitee};
        my $modules=$data->{modules};
        my $uses=$data->{uses};
        my $prereq=$data->{prereq};
        my $author=$data->{author};
        foreach (qw(kwalitee modules uses prereq files_array dirs_array author)) {
            delete $data->{$_};
        }
        
        my ($db_author,$db_dist);
        $db->txn_begin;
        # save author 
        eval { 
            $db_author=$db->resultset('Author')->find_or_create(pauseid=>$author);
            $db_dist=$db_author->add_to_dists({ 
                dist=>$dist->dist,
                %$data
            })
        };
        $db->txn_commit;
        print "DB ERROR: dist: $@" and next if $@; 

        # add stuff to other tables
        $db->txn_begin;
        eval {
            foreach my $m (@$modules) {
                $db_dist->add_to_modules($m);
            }
            foreach my $p (@$prereq) {
                $db_dist->add_to_prereq($p);
            }
            foreach my $u (values %$uses) {
                $db_dist->add_to_uses($u);
            }
        };
        if ($@) {
            $db->txn_rollback;
            $db_dist->cpants_errors($db_dist->cpants_errors."\nDB:\n$@");                   $kwalitee->{no_cpants_errors}=0;
            $kwalitee->{kwalitee}--;
        } else {
            $db->txn_commit;
        }

        $db->txn_begin;
        eval {$db_dist->add_to_kwalitee($kwalitee || {})};
        if ($@) {
            $db->txn_rollback;
            croak $dist->dist." DB kwalitee error: $@";
        } else {
            $db->txn_commit;
        }
    }
}

sub db {
    my $self=shift;
    return $self->_db if $self->_db;
   
    my $name = $INC{'Test/More.pm'} ? 'test_cpants' : 'cpants';
    return $self->_db(Module::CPANTS::DB->connect('dbi:Pg:dbname='.$name,$ENV{CPANTS_USER},$ENV{CPANTS_PWD}));
}

sub cpan_01mailrc {
    my $self=shift;
    return catfile($self->cpan,'authors','01mailrc.txt.gz');
}

sub cpan_02packages {
    my $self=shift;
    return catfile($self->cpan,'modules','02packages.details.txt.gz');
}

sub cpan_path_to_dist {
    my $self=shift;
    my $prefix=shift;
    return catfile($self->cpan,'authors','id',$prefix);
}



1;

__END__


=pod

=head1 NAME

Module::CPANTS::ProcessCPAN - Generate Kwalitee ratings for the whole CPAN

=head1 SYNOPSIS
  
=head1 DESCRIPTION

Run CPANTS on the whole of CPAN. Includes a DBIx::Class based DB abstraction layer. More docs soon...

=head1 WEBSITE

http://cpants.perl.org/

=head1 BUGS

Please report any bugs or feature requests, or send any patches, to
bug-module-cpants-analyse at rt.cpan.org, or through the web interface at
http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Module-CPANTS-ProcessCPAN.
I will be notified, and then you'll automatically be notified of progress
on your bug as I make changes.

=head1 AUTHOR

Thomas Klausner, <domm@cpan.org>, http://domm.zsi.at

Please use the perl-qa mailing list for discussing all things CPANTS:
http://lists.perl.org/showlist.cgi?name=perl-qa

=head1 LICENSE

This code is Copyright (c) 2003-2006 Thomas Klausner.
All rights reserved.

You may use and distribute this module according to the same terms
that Perl is distributed under.

=cut


