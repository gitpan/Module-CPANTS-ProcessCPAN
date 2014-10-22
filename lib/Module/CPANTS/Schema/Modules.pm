package Module::CPANTS::Schema::Modules;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn", "PK", "Core");
__PACKAGE__->table("modules");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('modules_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "dist",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "module",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "file",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "in_lib",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "in_basedir",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "is_core",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.04004 @ 2008-04-07 19:01:51
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ytn/Dy1fOKLYQ9WI63sfgg

__PACKAGE__->belongs_to("dist", "Module::CPANTS::Schema::Dist", { id => "dist" });


# You can replace this text with custom content, and it will be preserved on regeneration
1;
