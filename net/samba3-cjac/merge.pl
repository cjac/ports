#!/usr/bin/perl -w
use warnings;
use strict;

use Data::Dumper;
use lib 'lib';
use Log::Log4perl;

Log::Log4perl->init('log4perl.conf') or die "couldn't init logger: $!";

my $logger = Log::Log4perl->get_logger('merge');

$logger->debug("performing merge]");

sub usage {
	print "<$0> <command> [options]\n";
	print "<$0> krb5conf [input krb5.conf] [output krb5.conf]\n";

}

sub errlog {
	my( $package, $filename, $line ) = caller(1);
	print( Data::Dumper->Dump([$package, $filename, $line]) );

}

sub merge_krb5conf_file {
	my( $krb5conf_filename, $output_filename ) = @_;

	$krb5conf_filename = '/etc/krb5.conf' unless $krb5conf_filename;
	$output_filename   = '/tmp/krb5.conf' unless $output_filename;

	my @lines;
	do {
		open( my $fh, q{<}, $krb5conf_filename ) or die "can't open $krb5conf_filename: $!";
		@lines = <$fh>;
	};

	return;
}

my $command = shift( @ARGV );

$logger->debug( "command: [$command]" );

unless( $command ){
	$logger->debug( '$command unspecified' );
	usage();
	exit -2; # no command specified
}

my $return;
if($command =~ '/^krb5conf$/i'){
	$return = merge_krb5conf_file( @ARGV );
}

if( $return ){
	$logger->debug( 'command return value:' . "[$return]" );
	exit 0; # command success
}else{
	$logger->debug( 'command return value undefined' );
	exit -3; # command return value undefined
}

usage();

exit -1; # no commands run
