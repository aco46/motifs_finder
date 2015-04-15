use strict;
use warnings;

use motifs_finder;

my $app = motifs_finder->apply_default_middlewares(motifs_finder->psgi_app);
$app;

