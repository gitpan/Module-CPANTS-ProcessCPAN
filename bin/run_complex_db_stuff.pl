#!/usr/bin/perl
use strict; 
use warnings;
use Module::CPANTS::ProcessCPAN;
use Module::CPANTS::DB;
use Module::CoreList;
use Parse::CPAN::Authors;

my $path_cpan=shift(@ARGV);
die "Usage: $0 path/to/local/cpan/mirror" unless -d $path_cpan;

my $p=Module::CPANTS::ProcessCPAN->new($path_cpan);
my $dbh=$p->db->storage->dbh;


# fill dist references in prereq & uses
# todo: handle modules provided by core
{
    print "fill prereq with dist_ids\n";
    my $sth=$dbh->prepare("select distinct requires from prereq where in_dist is null order by requires");
    $sth->execute();
    while (my ($module)=$sth->fetchrow_array) {
        my $in_dist=$dbh->selectrow_array("select dist.id from dist,modules where dist.id=modules.dist AND modules.module=?",undef,$module);
        next unless $in_dist;
        $dbh->do("update prereq set in_dist=? where requires=?",undef,$in_dist,$module);
        $dbh->do("update uses set in_dist=? where module=?",undef,$in_dist,$module);
    }
}

{
    print "fill still missing uses with dist_ids\n";
    my $sth=$dbh->prepare("select distinct module from uses where in_dist is null order by module");
    $sth->execute();
    while (my ($uses)=$sth->fetchrow_array) {
        my $in_dist=$dbh->selectrow_array("select dist.id from dist,modules where dist.id=modules.dist AND modules.module=?",undef,$uses);
        next unless $in_dist;
        $dbh->do("update uses set in_dist=? where module=?",undef,$in_dist,$uses);
    }
}

# is_prereq
{
    print "is_prereq\n";
    my $sth=$dbh->prepare("select dist.id,author from dist,author where dist.author=author.id");
    $sth->execute;
    while (my ($distid,$authid)=$sth->fetchrow_array) {
        my $is_prereq=$dbh->selectrow_array("select count(prereq.id) from prereq,dist,author where prereq.dist=dist.id AND dist.author=author.id AND in_dist=? AND dist.author!=?",undef,$distid,$authid);
       $dbh->do("update kwalitee set is_prereq=1,kwalitee=kwalitee+1 where dist=?",undef,$distid) if $is_prereq>0; 
    }
}

# fill_authors
{
    print "fill authors\n";
    my $pca = Parse::CPAN::Authors->new($p->cpan_01mailrc);
    foreach my $auth ($pca->authors) {
        my $pauseid=$auth->pauseid;
        my $a=$p->db->resultset('Author')->find_or_create(pauseid=>$pauseid);
        foreach (qw(name email)) {
            $a->$_($auth->$_);
        }
        $a->update;
    }
}

# AUTHOR: num_dists, average
{
    print "calc authors num_dists and average kwalitee\n";
    my $sth=$dbh->prepare("select count(*) as num_dists,avg(kwalitee.kwalitee) as average,dist.author as id from dist,kwalitee where dist.id=kwalitee.dist group by author");
    $sth->execute;
    while (my @r=$sth->fetchrow_array) {
        $dbh->do("update author set num_dists=?,average_kwalitee=? where id=?",undef,@r);
    }
    $sth->finish;
    $dbh->do("update author set num_dists=0 where num_dists is null");
}

# RANKS
{ 
    print "calc authors rank in cpants game\n";
    foreach my $query ("select average_kwalitee,id from author where num_dists>=5 order by average_kwalitee desc",
    "select average_kwalitee,id from author where num_dists<5 AND num_dists>0 order by average_kwalitee desc")
    {
        my $sth=$dbh->prepare($query);
        $sth->execute;
        my $pos=0;my $cnt=0;my $k=0;
        my @done;
        while (my ($avg,$id)=$sth->fetchrow_array) {
            $cnt++;
            if ($k!=$avg) {
                $k=$avg;
                $pos=$cnt;
            }
            push(@done,[$pos,$id]);
        }
        foreach (@done) {
            $dbh->do("update author set rank=? where id=?",undef,@$_);
        }
    }
}


# 

