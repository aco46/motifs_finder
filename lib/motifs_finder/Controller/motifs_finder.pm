package motifs_finder::Controller::motifs_finder;
use Moose;
use namespace::autoclean;
use File::Temp qw | tempfile |;


BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

motifs_finder::Controller::motifs_finder - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path('/motifs_finder/') :Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{template} = 'index.mas';
}


sub name_var :Path('/test/') :Args(0) {
    my ($self, $c) = @_;


 # get variables from catalyst object
    my $params = $c->req->body_params();
    my $sequence = $c->req->param("sequence");
    my $widths_of_motifs = $c->req->param("widths_of_motifs");
    my $numbers_of_sites = $c->req->param("numbers_of_sites");


           # validate the Nucleic Acid in sequence. To ensure the return of line is not seen as a space.
my @seq;

if ($sequence =~ /^>/) {
	$sequence =~ s/[ \,\-\.\#\(\)\%\'\"\[\]\{\}\:\;\=\+\\\/]/_/gi;
	@seq = split(/\s/,$sequence);

 }
  
           # to generate temporary file name for the analysis    

my ($fh, $filename) =tempfile("templateXXXXX", DIR => '/home/production/cxgn/motifs_finder/tempfile_motif/');

          # to open and write and print the input file
open (my $out_fh, ">", $filename."_input.txt") || die ("\nERROR: the file ".$filename."_input.txt could not be found\n");
	
	print $out_fh join("\n",@seq); 

         # to run Gibbs motifs sampler

 # my $err = system("/home/production/programs/motif_sampler/Gibbs.x86_64 -h > /home/production/Desktop/ouput.txt");

  my $err = system("/home/production/programs/motif_sampler/Gibbs.linux ".$filename."_input.txt $widths_of_motifs $numbers_of_sites -W 0.8 -w 0.1 -p 50 -j 5 -i 500 -S 20 -C 0.5 -y -nopt -o ".$filename."_output -n");

   print STDOUT "print $err\n";


open (my $output_fh, "<", $filename."_output") || die ("\nERROR: the file ".$filename."_output could not be found\n");

my @string_result;

	while (my $line = <$output_fh>) {
		chomp $line;
		push @string_result, $line;
		print "$line\n";
		
 }

   

	$c->stash->{res} = join("<br/>", @string_result);

 # $c->stash->{outfile} = $filename."_output";

    $c->stash->{parameters} = "$sequence $widths_of_motifs $numbers_of_sites, @string_result";
                                 

    	$c->stash->{template} = '/output.mas';
};


=encoding utf8

=head1 AUTHOR

production,,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
