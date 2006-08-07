#!perl

use strict;
use warnings;

use Test::More;

use File::Spec;
use HTTP::Request;
use HTTP::Request::AsCGI;
use HTML::Mason::CGIHandler;
use HTML::Mason::FakeApacheHandler;
use CGI ();

my $HANDLER = 'HTML::Mason::FakeApacheHandler';

my @TESTS = (
  [ 'basic', 200, '/index.html',    
    qr{^path: /index.html$},
  ],

# this doesn't really test this particular module's functionality
#  [ 'notfound', 500, '/none',          
#    qr{internal server error}i,
#  ],

  [ 'path', 200, '/index.html/foo',
    qr{^path: /index.html\npath_info: /foo$},
  ],

  [ 'two slashes', 200, '/index.html/http://foo.com',
    qr{^path: /index.html\npath_info: /http://foo.com$},
  ],
);

plan tests => @TESTS * 2;

for my $Test (@TESTS) {
  my ($name, $status, $path, $expect) = @$Test;
  
  my $request = HTTP::Request->new( GET => "http://localhost.localdomain$path" );

  my $response;
  {
    my $c = HTTP::Request::AsCGI->new($request)->setup;
    
    my $mason = $HANDLER->new(
      data_dir  => File::Spec->rel2abs('./data'),
      comp_root => [ [ test_root => File::Spec->rel2abs('./t/root') ] ],
      error_mode => 'fatal',
    );
    
    eval { $mason->handle_request };
    $c->restore;
    $response = $c->response;
  }
  
  is   $response->code,    $status, "$name: status code is $status";
  like $response->content, $expect, "$name: content matches $expect";
}
