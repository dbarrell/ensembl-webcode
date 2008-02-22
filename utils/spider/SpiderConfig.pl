=pod

=head1 NAME

SpiderConfig.pl - "Swish-e Spider" configuration file for searching for broken links 
                  and error pages

=head1 DESCRIPTION

This is a configuration file for the spider.pl program provided
with the swish-e distribution.

This config makes Swish-e Spider script search for broken links and error pages
on any given web-site.

Usage: 

    spider.pl [config_file (SpiderConfig.pl by default)] <URL>

Note:

  spider.pl was slightly modified to use SpiderConfig.pl by default
  instead of SwishSpiderConfig.pl, just because I like the name of it :)
  It also was modified to accept URL(s) straight from command line, without specifying 

Futher information:

  http://swish-e.org/docs/spider.html
  
=cut

our @servers;

our %template = (
    agent       => 'swish-e spider http://swish-e.org/',
    email       => 'ensembl-admin@ebi.ac.uk',
    keep_alive  => 1,         # Try to keep the connection open
    max_wait_time => 15,      # This setting is the number of seconds to wait for data
                              # to be returned from each request
    ignore_robots_file => 1,  # This disables both robots.txt and the meta tag parsing
#   max_time    => 10,        # Max time to spider in minutes
#   max_files   => 20,        # Max files to spider
    delay_sec   => 0,         # Delay in seconds between requests
    ignore_robots_file => 0,  # Don't set that to one, unless you are sure.
    use_cookies => 1,         # True will keep cookie jar
                              # Some sites require cookies
                              # Requires HTTP::Cookies
    use_md5     => 1,         # If true, this will use the Digest::MD5
                              # module to create checksums on content
                              # This will very likely catch files
                              # with differet URLs that are the same
                              # content.  Will trap / and /index.html,
                              # for example.
    # Here are hooks to callback routines to validate urls and responses
    # Probably a good idea to use them so you don't try to index
    # Binary data.  Look at content-type headers!
    #test_url       => \&test_url,
    #test_response   => \&test_response,
    #filter_content  => \&filter_content,
    output_function => sub {  },
    spider_done     => \&spider_done,
);

sub test_response {
  ($uri, $server, $response, $content_chunk) = @_;
  if ($response->code >= 400) {
    print LOG $response->code.' ('.$response->message.') '.$uri."\n";
  }
  return 1;
}

sub filter_content {
  ($uri, $server, $response, $content) = @_;

  return 1;
}

sub spider_done {
  close ERROR_PAGES;
}

foreach my $url (@ARGV) {
  push @servers, {
    base_url => $url,
    %template,
  };
}

use Data::Dumper;
warn Dumper(\@servers);

if (scalar @servers) {
  open ERROR_PAGES, '>error_pages.log' or die "Can't open 'error_pages.log' for writing: $!";
}

1;