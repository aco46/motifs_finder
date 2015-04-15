use strict;
use warnings;
use Test::More;


use Catalyst::Test 'motifs_finder';
use motifs_finder::Controller::motifs_finder;

ok( request('/motifs_finder')->is_success, 'Request should succeed' );
done_testing();
