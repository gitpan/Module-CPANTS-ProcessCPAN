package Module::CPANTS::Schema::HistoryAuthor;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("history_author");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('public.history_author_id_seq'::text)",
    is_nullable => 0,
    size => 4,
  },
  "run",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "author",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "average_kwalitee",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "num_dists",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "rank",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->belongs_to("author", "Module::CPANTS::Schema::Author", { id => "author" });
__PACKAGE__->belongs_to("run", "Module::CPANTS::Schema::Run", { id => "run" });


# Created by DBIx::Class::Schema::Loader v0.04002 @ 2007-12-29 23:19:31
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:4no17OptqqrFpv+vpwmVOw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
