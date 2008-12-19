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
    qr{^path: /index\.html$},
  ],

# this doesn't really test this particular module's functionality
#  [ 'notfound', 500, '/none',          
#    qr{internal server error}i,
#  ],

  [ 'path', 200, '/index.html/foo',
    qr{^path: /index\.html\npath_info: /foo$},
  ],

  [ 'two slashes', 200, '/index.html/http://foo.com',
    qr{^path: /index\.html\npath_info: /http://foo\.com$},
  ],

  [ 'self url', 200, '/r/selfurl.html',
    qr{^http://localhost\.localdomain/r/selfurl\.html$},
  ],

  [ 'self url path', 200, '/r/selfurl.html/foo',
    qr{^http://localhost\.localdomain/r/selfurl\.html/foo
       \n /foo $}x,
  ],
);

plan tests => @TESTS * 4;

sub handle_ok {
  my ($request, $handler, $name, $test) = @_;
  my $status = $test->{status};
  my $expect = $test->{expect};
  my $response;
  {
    my $c = HTTP::Request::AsCGI->new($request)->setup;
    my $mason = $HANDLER->new(
      data_dir  => File::Spec->rel2abs('./data'),
      comp_root => [ [ test_root => File::Spec->rel2abs('./t/root') ] ],
      error_mode => 'fatal',
    );
    
    eval { $handler->($mason) };
    $c->restore;
    $response = $c->response;
  }

  is   $response->code,    $status, "$name: status code is $status";
  like $response->content, $expect, "$name: content matches $expect";
}

for my $Test (@TESTS) {
  for my $handler (
    [ basic  => sub { shift->handle_request } ],
    [ cgi    => sub { shift->handle_cgi_object(CGI->new) } ],
  ) {
    my ($name, $code) = @$handler;
    my ($base_name, $status, $path, $expect) = @$Test;
    
    
    my $request = HTTP::Request->new( GET => "http://localhost.localdomain$path" );
    handle_ok(
      $request, $code, "$base_name/$name",
      {
        status => $status,
        expect => $expect,
      },
    );
  }
}
