#!/usr/bin/perl
use strict;
use warnings;
 
use File::Spec::Functions;
use GD::Graph;
use GD::Graph::bars;
use Module::CPANTS::ProcessCPAN;
use Module::CPANTS::Schema;
use Module::CPANTS::ProcessCPAN::ConfigData;
my $home=Module::CPANTS::ProcessCPAN::ConfigData->config('home');

my $outpath=shift(@ARGV) || catdir($home,'root','static');

my $mcp=bless {},'Module::CPANTS::ProcessCPAN';
my $DBH=$mcp->db->storage->dbh;

my $now=localtime();
my @bar_defaults=(
    bar_spacing     => 8,
    shadow_depth    => 4,
    shadowclr       => 'dred',
    transparent     => 0,
    show_values=>1,
);

foreach (
    {
        title=>'Kwalitee Distribution',
        sql=>'select abs_kw,count(abs_kw) as cnt from kwalitee group by abs_kw order by abs_kw',
        lablex=>'Kwalitee',
        labley=>'Distributions',
    },
    {
        title=>'Active PAUSE IDs',
        sql=>[
            q{select 'active',count(*) from author where num_dists>0},
            q{select 'inactive',count(*) from author where num_dists=0},
            ],
        lablex=>'Status',
        labley=>'Authors',
    },
    {
        title=>'Dists per Author',
        sql=>'select num_dists,count(num_dists) as cnt from author where num_dists > 0 group by num_dists order by num_dists',
        lablex=>'Dists',
        labley=>'Authors',
        width=>800,
    },
    {
        title=>'Dists released per year',
        sql=>'select extract(year from released) as year,count(*) from dist group by year order by year',
        lablex=>'Year',
        labley=>'Dists',
    },

) {
    make_graph($_);
}

sub make_graph {
    my $c=shift;

    my $title=$c->{title};
    my $filename=lc($title);
    $filename=~s/ /_/g;
    $filename=~s/\W//g;
    $filename.=".png";
    
    my (@x,@y);
    my $maxy=0;

    if (ref($c->{sql}) eq 'ARRAY') {
        foreach my $sql (@{$c->{sql}}) {
            my $sth=$DBH->prepare($sql);
            $sth->execute;
            while (my @r=$sth->fetchrow_array) {
                my $x=shift(@r) || '';
                push(@x,$x);
                my $y=shift(@r);
                push(@y,$y);
                $maxy=$y if $y>$maxy;
            }
            $maxy=int($maxy*1.05);
        }
    } else {
        my $sth=$DBH->prepare($c->{sql});
        $sth->execute;

        while (my @r=$sth->fetchrow_array) {
            my $x=shift(@r) || '';
            push(@x,$x);
            my $y=shift(@r);
            push(@y,$y);
            $maxy=$y if $y>$maxy;
        }
        $maxy=int($maxy*1.05);
    }

    my $graph=GD::Graph::bars->new($c->{width} || 400,400);
    $graph->set(
		x_label=>$c->{lablex},
		'y_label'=>$c->{labley},
		title=>$title." ($now)",
		'y_max_value'=>$maxy,
		@bar_defaults,
    );

    my $gd=$graph->plot([\@x,\@y]);
    return unless $gd;
    my $outfile=catfile($outpath,$filename);
    open(IMG, ">",$outfile) or die "$outfile: $!";
    binmode IMG;
    print IMG $gd->png;
    return;
}

__END__


