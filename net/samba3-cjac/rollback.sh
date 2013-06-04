#!/bin/sh

. ./ADAuth.FreeBSD-6.3.Rollback
restore_config_files
leave_domain
disable_services
stop_services
purge_install_root
