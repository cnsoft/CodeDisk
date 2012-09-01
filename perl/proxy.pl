#!/usr/bin/perl
#  Simple HTTP Proxy Program using HTTP::Daemon.
#  (c) 2007 by Takaki Makino  http://www.snowelm.com/~t/

use strict;

use HTTP::Daemon;
use LWP::UserAgent;
use Data::Dumper;

my $ua = LWP::UserAgent->new();
my $d = HTTP::Daemon->new( 
	LocalHost => "192.168.1.5",  # remove this to listen from other machines 
				   # (i.e. open-relay... be careful of spammers!)
	LocalPort => 8089
) || die;
print "[Proxy URL:", $d->url, "]\n";

# Avoid dying from browser cancel
$SIG{PIPE} = 'IGNORE';

# Dirty pre-fork implementation
#fork(); fork(); fork();  # 2^3 = 8 processes

while (my $c = $d->accept) {
        while (my $request = $c->get_request) {
		print $c->sockhost . ": " . $request->uri->as_string . "\n";

		#$request->push_header( Via => "1.1 ". $c->sockhost );
		
		
		hook($request);
		
		my $response = $ua->simple_request( $request );

		$c->send_response( $response );
        
        open(F, '>', time() . '.txt');
        binmode F;
        print F Dumper($response);
        close F;
		# Save the response content into file
		#if( ($request->method eq "GET" || $request->method eq "POST") 
		#	&& $response->is_success && length($response->content) > 10 )
		#{
        #    print "get\n";
	#		my $uri = $request->uri->as_string;
	#		$uri =~ s#/#_#g;
	#		open(F, ">$uri") || print "Cannot write $uri\n";;
	#		print F $response->content;
	#		close F;
	#	}
	}
	$c->close;
	undef($c);
}


sub hook {
    my $request = shift;
    my $content = $request->content;
    my @params = split "&", $content;
    my $rh = {};
    for my $str (@params) {
        my @value = split '=', $str;
        if (@value == 2){
            $rh->{$value[0]} = $value[1];
            
        }
    }
    
    print Dumper($rh);
  
}