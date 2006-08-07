#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'HTML::Mason::FakeApacheHandler' );
}

diag( "Testing HTML::Mason::FakeApacheHandler $HTML::Mason::FakeApacheHandler::VERSION, Perl $], $^X" );
