package HTML::Mason::FakeApacheHandler;

use strict;
use warnings;

use base qw(HTML::Mason::CGIHandler);
use File::Spec;

=head1 NAME

HTML::Mason::FakeApacheHandler - emulate (more) Apache behavior under CGI

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

See HTML::Mason::CGIHandler for almost all behavior.

=head1 METHODS

=head2 handle_request

Overloaded to behave more like Apache in a very specific circumstance.

When receiving a CGI request for '/foo/bar', and '/foo' is a
component in the component root path, but '/foo/bar' does
not exist:

=over 4

=item * save '/foo' and execute it as the component

=item * set PATH_INFO from C</foo/bar> to C</bar> (the
'unclaimed' part of the original PATH_INFO)

=back

=head2 handle_cgi_object

See L<C<handle_request>|/handle_request>.

=cut

sub handle_request {
  my $self = shift;

  my ($comp, $path) = $self->_split_path($ENV{PATH_INFO});
  # if we couldn't find a component, let mason handle it
  return $self->SUPER::handle_request(@_) unless defined $comp;

  $ENV{PATH_INFO} = $path;
  return $self->_handler({ comp => $comp }, @_);
}

sub handle_cgi_object {
  my ($self, $cgi) = (shift, shift);

  my ($comp, $path) = $self->_split_path($cgi->path_info);
  return $self->SUPER::handle_cgi_object($cgi, @_) unless defined $comp;

  # set ENV also because some components are dumb
  $ENV{PATH_INFO} = $path;
  $cgi->path_info($path);
  return $self->_handler({
    comp => $comp,
    cgi  => $cgi,
  }, @_);
}

sub _split_path {
  my ($self, $path) = @_;
  my @path = split m!/!, $path;
  my @leftover;
  while (@path and ! $self->_comp_root_find(
    $self->interp->comp_root,
    File::Spec->catfile(@path),
  )) {
    unshift @leftover, pop @path;
  }

  return unless @path;

  # add an extra '' because we implicitly lost a '/' to split
  # XXX is this always true?
  return File::Spec->catfile(@path), join '/', '', @leftover;
}

sub __comp_root {
  my $comp_root = shift;
  return $comp_root if ref $comp_root eq 'ARRAY';
  return [ [ only_comp_root => $comp_root ] ];
}

sub _comp_root_find {
  my ($self, $comp_root, $path) = @_;
  for my $dir (map { $_->[1] } @{ __comp_root($comp_root) }) {
    return $dir if -e File::Spec->catfile($dir, $path);
  }
  return;
}

=head1 AUTHOR

Hans Dieter Pearcey, C<< <hdp at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-html-mason-fakeapachehandler at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=HTML-Mason-FakeApacheHandler>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc HTML::Mason::FakeApacheHandler

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/HTML-Mason-FakeApacheHandler>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/HTML-Mason-FakeApacheHandler>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=HTML-Mason-FakeApacheHandler>

=item * Search CPAN

L<http://search.cpan.org/dist/HTML-Mason-FakeApacheHandler>

=back

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2006 Hans Dieter Pearcey, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of HTML::Mason::FakeApacheHandler
