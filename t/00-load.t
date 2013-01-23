#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Webservice::Instagram' ) || print "Bail out!\n";
}

diag( "Testing Webservice::Instagram $Webservice::Instagram::VERSION, Perl $], $^X" );
