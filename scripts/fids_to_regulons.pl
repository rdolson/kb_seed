use strict;
use Data::Dumper;
use Carp;

#
# This is a SAS Component
#

=head1 fids_to_regulons

Example:

    fids_to_regulons [arguments] < input > output

The standard input should be a tab-separated table (i.e., each line
is a tab-separated set of fields).  Normally, the last field in each
line would contain the identifer. If another column contains the identifier
use

    -c N

where N is the column (from 1) that contains the subsystem.

This is a pipe command. The input is taken from the standard input, and the
output is to the standard output.

=head2 Documentation for underlying call

This script is a wrapper for the CDMI-API call fids_to_regulons. It is documented as follows:

  $return = $obj->fids_to_regulons($fids)

=over 4

=item Parameter and return types

=begin html

<pre>
$fids is a fids
$return is a reference to a hash where the key is a fid and the value is a regulon_size_pairs
fids is a reference to a list where each element is a fid
fid is a string
regulon_size_pairs is a reference to a list where each element is a regulon_size_pair
regulon_size_pair is a reference to a list containing 2 items:
	0: a regulon
	1: a regulon_size
regulon is a string
regulon_size is an int

</pre>

=end html

=begin text

$fids is a fids
$return is a reference to a hash where the key is a fid and the value is a regulon_size_pairs
fids is a reference to a list where each element is a fid
fid is a string
regulon_size_pairs is a reference to a list where each element is a regulon_size_pair
regulon_size_pair is a reference to a list containing 2 items:
	0: a regulon
	1: a regulon_size
regulon is a string
regulon_size is an int


=end text

=back

=head2 Command-Line Options

=over 4

=item -c Column

This is used only if the column containing the subsystem is not the last column.

=item -i InputFile    [ use InputFile, rather than stdin ]

=back

=head2 Output Format

The standard output is a tab-delimited file. It consists of the input
file with extra columns added.

Input lines that cannot be extended are written to stderr.

=cut

use SeedUtils;

my $usage = "usage: fids_to_regulons [-c column] < input > output";

use CDMIClient;
use ScriptThing;

my $column;

my $input_file;

my $kbO = CDMIClient->new_for_script('c=i' => \$column,
				      'i=s' => \$input_file);
if (! $kbO) { print STDERR $usage; exit }

my $ih;
if ($input_file)
{
    open $ih, "<", $input_file or die "Cannot open input file $input_file: $!";
}
else
{
    $ih = \*STDIN;
}

while (my @tuples = ScriptThing::GetBatch($ih, undef, $column)) {
    my @h = map { $_->[0] } @tuples;
    my $h = $kbO->fids_to_regulons(\@h);
    for my $tuple (@tuples) {
        #
        # Process output here and print.
        #
        my ($id, $line) = @$tuple;
        my $v = $h->{$id};

        if (! defined($v))
        {
            print STDERR $line,"\n";
        }
        elsif (ref($v) eq 'ARRAY')
        {
	     print "$line\t$v->[1]\t$v->[0]\n";
        }
        else
        {
            print "$line\t$v\n";
        }
    }
}