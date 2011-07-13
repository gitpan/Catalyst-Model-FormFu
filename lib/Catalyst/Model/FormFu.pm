package Catalyst::Model::FormFu;
BEGIN {
  $Catalyst::Model::FormFu::VERSION = '0.003';
}

# ABSTRACT: Speedier interface to HTML::FormFu for Catalyst

use strict;
use warnings;
use HTML::FormFu;
use HTML::FormFu::Library;
use Moose;
use namespace::clean -except => 'meta';

extends 'Catalyst::Model';
with 'Catalyst::Component::InstancePerContext';

has model_stash => ( is => 'ro', isa => 'HashRef' );
has constructor => ( is => 'ro', isa => 'HashRef', default => sub { {} } );
has forms       => ( is => 'ro', required => 1, isa => 'HashRef' );
has cache       => ( is => 'ro', required => 1, isa => 'HashRef', builder => '_build_cache' );

sub _build_cache
{
    my $self = shift;

    my %cache;

    while ( my ($id, $config_file) = each %{$self->forms} )
    {
        my %args = ( query_type => 'Catalyst', %{$self->constructor} );
        my $form = HTML::FormFu->new(\%args);
        $form->load_config_file($config_file);
        $cache{$id} = $form;
    }

    return \%cache;
}

sub build_per_context_instance {

    my ($self, $c) = @_;

    my %args = (
        cache => $self->cache,
        query => $c->request->query_parameters,
    );

    $args{model} = $c->model($self->model_stash->{schema}) if $self->model_stash;

    return HTML::FormFu::Library->new(%args);
}

__PACKAGE__->meta->make_immutable;


__END__
=pod

=for :stopwords Peter Shangov precompiled BackPAN Daisuke Maki

=head1 NAME

Catalyst::Model::FormFu - Speedier interface to HTML::FormFu for Catalyst

=head1 VERSION

version 0.003

=head1 SYNOPSIS

    package MyApp
    {

        use parent 'Catalyst';

        __PACKAGE__->config( 'Model::FormFu' => {
            model_stash => { schema => 'MySchema' },
            constructor => { config_file_path => 'myapp/root/forms' },
            forms => {
                form1 => 'form1.yaml',
                form2 => 'form2.yaml',
            ]
        } );

    }

    package MyApp::Controller::WithForms
    {
        use parent 'Catalyst::Controller';

        sub edit :Local
        {
            my ($self, $c, @args) = @_;

            my $form1 = $c->model('FormFu')->form('form1');

            if ($form1->submitted_and_valid)
            ...
        }

    }

    package MyApp::Model::FormFu
    {
        use parent 'Catalyst::Model::FormFu';
    }

=head1 DESCRIPTION

C<Catalyst::Model::FormFu> is an alternative interface for using L<HTML::FormFu> within L<Catalyst>. It differs from L<Catalyst::Controller::HTML::FormFu> in the following ways:

=over 4

=item *

It initializes all required form objects when your app is started, and returns clones of these objects in your actions. This avoids having to call L<HTML::FormFu/load_config_file> and L<HTML::FormFu/populate> every time you display a form, leading to performance improvements in persistent applications.

=item *

It does not inherit from L<Catalyst::Controller>, and so is safe to use with other modules that do so, in particular L<Catalyst::Controller::ActionRole>.

=back

Note that this is a completely different module from the original C<Catalyst::Model::FormFu> by L<Daisuke Maki|http://search.cpan.org/~dmaki/>, which is now only available on the BackPAN (L<http://backpan.perl.org/authors/id/D/DM/DMAKI/Catalyst-Model-FormFu-0.01001.tar.gz>).

=head1 CONFIGURATION OPTIONS

C<Catalyst::Model::FormFu> accepts the following configuration options

=over

=item forms

A hashref where keys are the names by which the forms will be accessed, and the values are the configuration files that will be loaded for the respective forms.

=item constructor

A hashref of options that will be passed to C<HTML::FormFu-E<gt>new(...)> for every form that is created.

=item model_stash

A hashref with a C<stash> key whose value is the name of a Catalyst model class that will be place in the form stash for use by L<HTML::FormFu::Model::DBIC>.

=back

=head1 USAGE

Use the C<form> method of the model to fetch one or more forms by their names. The form is loaded with the current request parameters and processed.

=head1 SEE ALSO

=over 4

=item *

L<Catalyst::Controller::HTML::FormFu>

=item *

L<HTML::FormFu::Library>

=back

=head1 AUTHOR

Peter Shangov <pshangov@yahoo.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Peter Shangov.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
