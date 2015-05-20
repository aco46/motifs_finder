package motifs_finder::Controller::motifs_finder;
use Moose;
use namespace::autoclean;
use File::Temp qw | tempfile |;
use File::Basename;

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
    my $weblogo_output = $c->config->{tmp_weblogo_path};



           # validate the Nucleic Acid in sequence. To ensure the return of line is not seen as a space.
	my @seq;

	if ($sequence =~ /^>/) {
		$sequence =~ s/[ \,\-\.\#\(\)\%\'\"\[\]\{\}\:\;\=\+\\\/]/_/gi;
		@seq = split(/\s/,$sequence);

	}
  
        # to generate temporary file name for the analysis    
	my ($fh, $filename) =tempfile("XXXXX", DIR => '/home/production/cxgn/motifs_finder/root/static/tempfile_motif/');

          # to open and write and print the input file
	open (my $out_fh, ">", $filename."_input.txt") || die ("\nERROR: the file ".$filename."_input.txt could not be found\n");
	
		print $out_fh join("\n",@seq); 


         # to run Gibbs motifs sampler

  	my $err = system("/home/production/programs/motif_sampler/Gibbs.linux ".$filename."_input.txt $widths_of_motifs $numbers_of_sites -W 0.8 -w 0.1 -p 50 -j 5 -i 500 -S 20 -C 0.5 -y -nopt -o ".$filename."_output -n");

   		print STDOUT "print $err\n";


	open (my $output_fh, "<", $filename."_output") || die ("\nERROR: the file ".$filename."_output could not be found\n");


        
      # Creating motifs fasta file for weblogo use 

my $switch = 0;
my $motif = 0;
my $switch_logo = 0;
my $logo = 0;
my @string_result;
my $logo_file;
my $wl_out_fh;
my @motif_element;
my @logo_image;
my @logofile_id;
my $lf_id;
	
	while (my $line = <$output_fh>) {
		chomp $line;
		push @string_result, $line;
		

	if ($motif == 1){
		$switch++;
		
		
			if ($logo == 1 && $line !~ m/^\s+\*+/ ) {
				$switch_logo++;
				my @a = split(/\s+/,$line);
				print  $wl_out_fh ">seq_$switch_logo\n$a[5]\n";
				
			}
				
		        if ($line =~ m/^Num\sMotifs/ ) {
			     $logo = 1;	
			     open ($wl_out_fh, ">", $logo_file) || die ("\nERROR: the file $logo_file could not be found\n");
			     push @motif_element, $logo_file;
			     push @logofile_id, $lf_id;
			     print "logo file ID: @logofile_id\n";
			     
			}
	
		        elsif ($line =~ m/^\s+\*+/ ) {
				$logo = 0;
		     		
			}
				
	}

	if ($line =~ m/^\s+MOTIF\s+([a-z])/){
		$motif = 1;	
		$logo_file = $filename."_".$1."_wl_input.fasta";
		$lf_id = $1;
	}
	
	elsif ($line =~ m/^Log\s+Fragmentation\s+portion\s+/ ) {
			$motif = 0;
			close $wl_out_fh;
			
			
			
	}	


   	}

# To run weblogo
my $cmd;

	foreach $filename (@motif_element){	
		$cmd = "/home/production/programs/weblogo/seqlogo -F PNG -d 0.5 -T 1 -B 2 -h 5 -w 18 -y bits -a -M -n -Y -c -f $filename -o ".$filename."_weblogo";
		push (@logo_image, basename($filename."_weblogo.png"));
		my $error = system($cmd);
	
	}
 		 

$c->stash->{res} = join("<br/>", @string_result);	
$c->stash->{outfile} = $filename."_output";
$c->stash->{parameters} = "$sequence $widths_of_motifs $numbers_of_sites @string_result";
$c->stash->{logo} = \@logo_image;  
$c->stash->{logoID} = \@logofile_id;                               

    	$c->stash->{template} = '/output.mas';
}


=encoding utf8

=head1 AUTHOR

production,,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
