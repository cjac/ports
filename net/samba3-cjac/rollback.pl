#!/usr/bin/perl -w

use strict;
sub restore_config_files {
    open( my $fh, q{|/bin/sh} );
    print $fh (
	       ". ./ADAuth.FreeBSD-6.3.Rollback\n",
	       "restore_config_files\n",
	      );
    close $fh;
}

restore_config_files();
