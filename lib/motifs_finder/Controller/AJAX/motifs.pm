package motifs_finder::Controller::AJAX::motifs;

use Moose;

use File::Basename;
use File::Slurp;
use File::Spec;
use Data::Dumper;
use File::Temp qw | tempfile |; 
#use motifs_finder::Role::Site::Files;


BEGIN { extends 'Catalyst::Controller::REST' }

__PACKAGE__->config(
    default => 'application/json',
    stash_key => 'rest',
    map => { 'application/json' => 'JSON', 'text/html' => 'JSON' },
   );

our %urlencode;


sub upload_sequence_file_for_motifs : Path('/AJAX/upload_sequence_file') : ActionClass('REST') { }

sub upload_sequence_file_for_motifs_POST : Args(0) {
    my ($self, $c) = @_;

    my $upload = $c->req->upload("sequence_file");
    my $seq_file = undef;

    if (defined($upload)) {
	$seq_file = $upload->tempname;    
	$seq_file =~ s/\/tmp\///;
print "SEQ FILE: $seq_file\n";
	#my $seq_dir = $c->generated_file_uri('seq_files', $seq_file);
	#my $final_path = $c->path_to($seq_dir);
	my $final_path = $c->config->{tmp_weblogo_path}."/$seq_file";

	write_file($final_path, $upload->slurp);
    }
    
    $c->stash->{rest} = {
      seq_file => $seq_file,
      success => "1",
    };
}



1;
