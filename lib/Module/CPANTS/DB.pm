package Module::CPANTS::DB;
use strict;
use warnings;

use base qw(DBIx::Class::Schema);
__PACKAGE__->load_classes(qw(Dist Kwalitee Run Modules Prereq Uses Author));

our $VERSION=0.60;



'Listening to: Attwenger - dog'
