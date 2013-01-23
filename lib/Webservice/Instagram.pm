package Webservice::Instagram;

use 5.006;
use strict;
use warnings;

use JSON;
use LWP::UserAgent;
use URI;
use Carp;
use Data::Dumper;
use HTTP::Request;

our $VERSION = '0.01';

use constant AUTHORIZE_URL 	=> 'https://api.instagram.com/oauth/authorize?';
use constant ACCESS_TOKEN_URL 	=> 'https://api.instagram.com/oauth/access_token?';

sub new {
	my ($class, $self) = @_;
	foreach ( qw(client_id client_secret redirect_uri) ) {
		confess "Oops! $_ not provided" if ( ! defined $self->{$_} );
	}
	$self->{browser} = LWP::UserAgent->new();
	bless $self, $class;
	return $self;
}

sub get_auth_url { 
	my $self = shift;
	carp "User already authorized with code: $self->{code}" if $self->{code};
	my @auth_fields = qw(client_id redirect_uri response_type);
	$self->{response_type} = 'code';
	foreach ( @auth_fields ) {
		confess "ERROR: $_ required for generating authorization URL." if (!defined $_);
	}
	my $auth_base_url = "https://api.instagram.com/oauth/authorize/?";
	#print Dumper $self->{client_id};
	my $return_url = AUTHORIZE_URL . join("&", ( map { $_ . "=" . $self->{$_} } @auth_fields) );
	return $return_url;
}

sub set_code {
	my $self = shift;
	$self->{code} = shift || confess "Code not provided";
	return $self;
}

sub get_access_token {
	my $self = shift;
	my @access_token_fields = qw(client_id redirect_uri grant_type client_secret code);
	$self->{grant_type} = 'authorization_code';
	foreach ( @access_token_fields ) {
		confess "ERROR: $_ required for building access token." if (!defined $_);
	}
	my $params = {};
	@$params{ @access_token_fields } = @$self{ @access_token_fields };	
	
	my $uri = URI->new( ACCESS_TOKEN_URL );
        my $req = new HTTP::Request POST => $uri->as_string; 
        $uri->query_form($params);
        $req->content_type('application/x-www-form-urlencoded'); 
        $req->content($uri->query); 
        my $res = from_json($self->{browser}->request($req)->content); 
#	print Dumper $res;
#	$self->{access_token} = $res->{access_token};
	return $res->{access_token};
}

sub set_access_token {
	my $self = shift;
	$self->{access_token} = shift || die "No access token provided";
}

sub request {
	my ( $self, $url, $params ) = @_;
	croak "access_token not passed" unless defined $self->{access_token} ;
	$params->{access_token} = $self->{access_token};
	my $uri = URI->new( $url );
        $uri->query_form($params);
	my $response = $self->{browser}->get($uri->as_string);
	my $ret = $response->decoded_content;
	return decode_json $ret;
}


=head1 NAME

Webservice::Instagram - Simple Interface to Instagram oAuth API

=head1 VERSION

Version 0.01

=cut

=head1 SYNOPSIS

=head2 Step 1:

Get the AUTH URL to authenticate,

C<
use Webservice::Instagram;

my $instagram = Webservice::Instagram->new(
	{
		client_id	=> 'xxxxxxxxxxxxxxx',
		client_secret	=> 'xxxxxxxxxxxxxxx',
		redirect_uri	=> 'http://domain.com',
		grant_type	=> 'authorization_code'
	}
);

my $auth_url = $obj->get_auth_url();
print Dumper $auth_url;
>

=head2 Step 2:
Go to the above calculated URL in the browser, authenticate and fetch the code returned by the browser after authentication.
The returned URL is usually of the form www.returnuri.com/?code=xxxxxxxxxxx

=head2 Step 3:

Now using the code, fetch the access_token and set it to the object,

C<
my $access_token = $obj->get_access_token( $code ); #$code is fetched from Step 2.
#Set the access_token to $instagram object
$instagram->set_access_token( $access_token );
>

=head2 Step 3:
Fetch resource using the object.

C<
my $search_result = $obj->get( 'https://api.instagram.com/v1/users/search', { q => 'ravi' } };
>

=head1 SUBROUTINES/METHODS

=head2 get_auth_url

Returns the authorization URL that the user has to authorize against. Once authorized, the browser appends the C<code> along to the redirect URL which will used for obtaining access_token later.
=cut

=head2 get_access_token

Once you have the C<code>, you are ready to get the access_token. 

=cut

=head2 get

Since you now have the access token, you can request all the resources on behalf of the API. 
=cut

=head1 AUTHOR

Daya Sagar Nune, C<< <dayanune at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-webservice-instagram at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Webservice-Instagram>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Webservice::Instagram


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Webservice-Instagram>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Webservice-Instagram>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Webservice-Instagram>

=item * Search CPAN

L<http://search.cpan.org/dist/Webservice-Instagram/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2013 Daya Sagar Nune.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of Webservice::Instagram
