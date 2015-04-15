package motifs_finder::View::Mason;
use Moose;
use namespace::autoclean;
use strict;
use warnings;
use Moose;
use Moose::Util::TypeConstraints;

extends 'Catalyst::View::HTML::Mason';
with 'Catalyst::Component::ApplicationAttribute';

__PACKAGE__->config(
    template_extension => '.mas',
    interp_args => {
	comp_root => [
	    [ main => motifs_finder->path_to('mason') ],
        ],
    },
);

=head1 NAME

motifs_finder::View::Mason - TT View for motifs_finder

=head1 DESCRIPTION

TT View for motifs_finder.

=head1 SEE ALSO

L<motifs_finder>

=head1 AUTHOR

production,,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
