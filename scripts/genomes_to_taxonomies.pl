use strict;
use Data::Dumper;
use Carp;

#
# This is a SAS Component
#

=head1 NAME

genomes_to_taxonomies

=head1 SYNOPSIS

genomes_to_taxonomies [arguments] < input > output

=head1 DESCRIPTION


The routine genomes_to_taxonomies can be used to retrieve taxonomic information for
each of a list of input genomes.  For each genome in the input list of genomes, a list of
taxonomic groups is returned.  Kbase will use the groups maintained by NCBI.  For an NCBI
taxonomic string like

     cellular organisms;
     Bacteria;
     Proteobacteria;
     Gammaproteobacteria;
     Enterobacteriales;
     Enterobacteriaceae;
     Escherichia;
     Escherichia coli

associated with the strain 'Escherichia coli 1412', this routine would return a list of these
taxonomic groups:


     ['Bacteria',
      'Proteobacteria',
      'Gammaproteobacteria',
      'Enterobacteriales',
      'Enterobacteriaceae',
      'Escherichia',
      'Escherichia coli',
      'Escherichia coli 1412'
     ]

That is, the initial "cellular organisms" has been deleted, and the strain ID has
been added as the last "grouping".

The output is a mapping from genome IDs to lists of the form shown above.


Example:

    genomes_to_taxonomies [arguments] < input > output

The standard input should be a tab-separated table (i.e., each line
is a tab-separated set of fields).  Normally, the last field in each
line would contain the identifer. If another column contains the identifier
use

    -c N

where N is the column (from 1) that contains the subsystem.

This is a pipe command. The input is taken from the standard input, and the
output is to the standard output.

=head1 COMMAND-LINE OPTIONS

Usage: genomes_to_taxonomies [arguments] < input > output


    -c num        Select the identifier from column num
    -i filename   Use filename rather than stdin for input

=head1 AUTHORS

L<The SEED Project|http://www.theseed.org>

=cut


our $usage = "usage: genomes_to_taxonomies [-c column] < input > output";

use Bio::KBase::CDMI::CDMIClient;
use Bio::KBase::Utilities::ScriptThing;

my $column;

my $input_file;

my $kbO = Bio::KBase::CDMI::CDMIClient->new_for_script('c=i' => \$column,
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

while (my @tuples = Bio::KBase::Utilities::ScriptThing::GetBatch($ih, undef, $column)) {
    my @h = map { $_->[0] } @tuples;
    my $h = $kbO->genomes_to_taxonomies(\@h);
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
		my $a = join(": ", @$v);
                print "$line\t$a\n";
        }
        else
        {
            print "$line\t$v\n";
        }
    }
}

__DATA__
