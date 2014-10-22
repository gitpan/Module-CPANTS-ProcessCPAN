package Module::CPANTS::Schema::Kwalitee;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("kwalitee");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('public.kwalitee_id_seq'::text)",
    is_nullable => 0,
    size => 4,
  },
  "dist",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "run",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "abs_kw",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "abs_core_kw",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "kwalitee",
  { data_type => "numeric", default_value => 0, is_nullable => 0, size => "3,6" },
  "rel_core_kw",
  { data_type => "numeric", default_value => 0, is_nullable => 0, size => "3,6" },
  "extractable",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "extracts_nicely",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "has_version",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "has_proper_version",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "no_cpants_errors",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "has_readme",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "has_manifest",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "has_meta_yml",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "has_buildtool",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "has_changelog",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "no_symlinks",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "has_tests",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "proper_libs",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "is_prereq",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "use_strict",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "use_warnings",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "has_test_pod",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "has_test_pod_coverage",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "no_pod_errors",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "has_working_buildtool",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "manifest_matches_dist",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "has_example",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "buildtool_not_executable",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "has_humanreadable_license",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "metayml_is_parsable",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "metayml_conforms_spec_current",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "metayml_has_license",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "metayml_conforms_to_known_spec",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "has_license",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "prereq_matches_use",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "build_prereq_matches_use",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->belongs_to("dist", "Module::CPANTS::Schema::Dist", { id => "dist" });
__PACKAGE__->belongs_to("run", "Module::CPANTS::Schema::Run", { id => "run" });


# Created by DBIx::Class::Schema::Loader v0.04002 @ 2007-12-29 23:19:31
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:oQeJoLzJAN8HyzTcaK5WGw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
