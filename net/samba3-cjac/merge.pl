#!/usr/bin/perl -w
use warnings;
use strict;

use Data::Dumper;
use lib 'lib';
use Log::Log4perl;

Log::Log4perl->init('log4perl.conf') or die "couldn't init logger: $!";

my $logger = Log::Log4perl->get_logger('merge');

$logger->debug("performing merge");

my $TAOS_RELEASE =
	exists $ENV{TAOS_RELEASE} ?
	$ENV{TAOS_RELEASE} :
	'http://www.colliertech.org/~cjac/nis-migration';

my $DOMAIN =
	exists $ENV{DOMAIN} ?
	$ENV{DOMAIN} :
	'ESD.COLLIERTECH.ORG';

my $PDCHOSTS =
	exists $ENV{PDCHOSTS} ?
	$ENV{PDCHOSTS} :
	`dig +short _kerberos._udp.${DOMAIN} SRV |
   grep -v '^;' |
   awk '{print \$4}' |
   sed -e 's/\.\$//'`;

chomp $PDCHOSTS;

$logger->debug( "PDCHOSTS: [$PDCHOSTS]" );

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

	open( my $fh, q{<}, $krb5conf_filename ) or die "can't open $krb5conf_filename: $!";
	my @lines = <$fh>;
	close($fh);

	my $section = 'none';
	my $realm = 'other';

	my %section_value = ( $section => [] );
	my %realm_value = ( $realm => [] );

	my @section_order;

	push(@section_order, $section);

	while( my $line = shift( @lines ) ){
		if( $line =~ m{^\s*\[(.*?)\]\s*$} ){
			$section = $1;
			push(@section_order, $section);
			next;
		}

		if($section eq 'realms'){
			if($realm eq 'other' and $line =~ m{${DOMAIN}\s*\{}){
				$realm = ${DOMAIN};
				next;
			}

			if($realm eq ${DOMAIN}){
				if( $line =~ m/{/){
					print("Merge ${DOMAIN} [realms] entry from ${TAOS_RELEASE}/krb5.conf into $krb5conf_filename manually\n");

					# TODO: Config::Any?
					return -4; # can't parse complex [realm] configs
				}
				if( $line =~ m/}/ ){
					$realm = 'other';
					next;
				}else{
					push( @{$realm_value{$realm}}, $line );
					next;
				}
			}else{
				push( @{$realm_value{$realm}}, $line );
				next;
			}
		}

		push(@{ $section_value{$section} }, $line);
	}

	my $output;

	foreach $section ( @section_order ){
		next unless exists $section_value{$section};

		@lines = @{$section_value{$section}};

		my $section_content = '';
		if ($section eq 'libdefaults') {
			my $dns_lookup_realm_set = 0;
			my $dns_lookup_kdc_set = 0;
			my $default_realm_set = 0;

			foreach my $line (@lines) {

				if ( $line =~ m{^(\s*dns_lookup_realm\s*=\s*)(.*?)$} ) {
					$line = $1."1\n";
					$dns_lookup_realm_set = 1;
					$logger->debug( "dns_lookup_realm processed" );
				}

				if ( $line =~ m{^(\s*dns_lookup_kdc\s*=\s*)(.*?)$} ) {
					$line = $1."1\n";
					$dns_lookup_kdc_set = 1;
					$logger->debug( "dns_lookup_kdc processed" );
				}

				if ( $line =~ m{^(\s*default_realm\s*=\s*)(.*?)$} ) {
					$line = $1."${DOMAIN}\n";
					$default_realm_set = 1;
					$logger->debug( "default_realm processed" );
				}

				$section_content .= $line;
			}

			$section_content .= "	dns_lookup_realm = 1\n"         unless $dns_lookup_realm_set;
			$section_content .= "	dns_lookup_kdc = 1\n"           unless $dns_lookup_kdc_set;
			$section_content .= "	default_realm = ${DOMAIN}\n"    unless $default_realm_set;

		} elsif ($section eq 'realms') {
			my $realm_content = "${DOMAIN} = {\n";
			my @pdc_hosts = split(/\s+/, ${PDCHOSTS});

			$logger->debug( Data::Dumper::Dumper( { pdc_hosts => \@pdc_hosts } ) );

			foreach my $kdc (@pdc_hosts){
						$realm_content .= "  kdc = tcp/$kdc\n";
						$realm_content .= "  kdc = udp/$kdc\n";
			}
			$realm_content .= "}\n\n";
			my $other_content = join('', @{$realm_value{'other'}});

			$section_content = "$realm_content\n\n$other_content";

		}else {
			$section_content = join('',@lines);
		}

		unless ($section eq 'none'){
			$output .= "[$section]\n";
		}

		$output .= "$section_content\n\n";
	}

	open($fh, q{>}, $output_filename ) or die "can't open $output_filename: $!";
	print $fh $output;

	return 1;
}

my $command = shift( @ARGV );

$logger->debug( "command: [$command]" );

unless( $command ){
	$logger->debug( '$command unspecified' );
	usage();
	exit -2; # no command specified
}

my $return;

if($command =~ /^krb5conf$/i){
	$return = merge_krb5conf_file( @ARGV );
	$logger->debug("krb5conf command returned: [$return]");
}

if( $return ){

	$logger->debug( "command return value: [$return]" );
	exit 0; # command success
}else{
	$logger->debug( 'command return value undefined' );
	exit -3; # command return value undefined
}

usage();

exit -1; # no commands run
