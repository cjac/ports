#!/bin/sh
#
# $FreeBSD: ports/net/samba35/files/samba.in,v 1.1 2010/10/26 02:41:58 timur Exp $
#

# PROVIDE: nmbd smbd
# PROVIDE: winbindd
# REQUIRE: NETWORKING SERVERS DAEMON ldconfig resolv
# REQUIRE: cupsd
# BEFORE: LOGIN
# KEYWORD: shutdown
#
# Add the following lines to /etc/rc.conf.local or /etc/rc.conf
# to enable this service:
#
#samba_enable="YES"
# or, for fine grain control:
#nmbd_enable="YES"
#smbd_enable="YES"
# You need to enable winbindd separately, by adding:
winbindd_enable="YES"
LD_LIBRARY_PATH="/opt/taos/samba3/lib/:$LD_LIBRARY_PATH"
PATH="/opt/taos/samba3/bin:/opt/taos/samba3/sbin"
#
# Configuration file can be set with:
samba_config="/opt/taos/samba3/etc/samba/smb.conf"
#

. /etc/rc.subr

name="samba"
rcvar=$(set_rcvar)
set_rcvar ${rcvar} "NO" "Samba service" > /dev/null
# Defaults
eval ${rcvar}=\${${rcvar}:=NO}
samba_config_default="/opt/taos/samba3/etc/smb.conf"
samba_config=${samba_config="${samba_config_default}"}
command_args=${samba_config:+-s "${samba_config}"}
# Fetch parameters from configuration file
testparm_command="/opt/taos/samba3/bin/testparm"
smbcontrol_command="/opt/taos/samba3/bin/smbcontrol"
samba_parm="${testparm_command} -s -v --parameter-name"
samba_idmap=$(${samba_parm} 'idmap uid' "${samba_config}" 2>/dev/null)
samba_lockdir=$(${samba_parm} 'lock directory' "${samba_config}" 2>/dev/null)
# Load configuration
load_rc_config "${name}"
# Setup dependent variables
if [ -n "${rcvar}" ] && checkyesno "${rcvar}"; then
    nmbd_enable=${nmbd_enable=YES}
    smbd_enable=${smbd_enable=YES}
    # Check that winbindd is actually configured
    if [ -n "${samba_idmap}" ]; then
        winbindd_enable=${winbindd_enable=YES}
    fi
fi
# XXX: Hack to enable check of the dependent variables
eval real_${rcvar}="\${${rcvar}:=NO}"   ${rcvar}=YES
# nmbd
nmbd_enable=${nmbd_enable:=NO}
nmbd_flags=${nmbd_flags="-D"}
set_rcvar nmbd_enable "NO" "nmb daemon" >/dev/null
# smbd
smbd_enable=${smbd_enable:=NO}
smbd_flags=${smbd_flags="-D"}
set_rcvar smbd_enable "NO" "smb daemon" >/dev/null
# winbindd
winbindd_enable=${winbindd_enable:=NO}
winbindd_flags=${winbindd_flags=''}
set_rcvar winbindd_enable "NO" "winbind daemon" >/dev/null
# Custom commands
extra_commands="reload status"
start_precmd="samba_start_precmd"
start_cmd="samba_cmd"
stop_cmd="samba_cmd"
status_cmd="samba_cmd"
restart_precmd="samba_checkconfig"
reload_precmd="samba_checkconfig"
reload_cmd="samba_reload_cmd"
rcvar_cmd="samba_rcvar_cmd"
#
samba_daemons="nmbd smbd"
samba_daemons="${samba_daemons} winbindd"
# Requirements
required_files="${samba_config}"
required_dirs="${samba_lockdir}"

samba_checkconfig() {
    echo -n "Performing sanity check on Samba configuration: "
    if ${testparm_command} -s ${samba_config:+"${samba_config}"} >/dev/null 2>&1; then
        echo "OK"
    else
        echo "FAILED"
        return 1
    fi
    return 0
}

samba_start_precmd() {
    # XXX: Never delete winbindd_idmap, winbindd_cache and group_mapping
    if [ -n "${samba_lockdir}" -a -d "${samba_lockdir}" ]; then
        echo -n "Removing stale Samba tdb files: "
        for file in brlock.tdb browse.dat connections.tdb gencache.tdb \
                    locking.tdb messages.tdb namelist.debug sessionid.tdb \
                    unexpected.tdb
        do
            rm "${samba_lockdir}/${file}" </dev/null 2>/dev/null && echo -n '.'
        done
        echo " done"
    fi
}

samba_rcvar_cmd() {
    local rcvar
    rcvar=$(set_rcvar ${name})
    eval ${rcvar}=\${real_${rcvar}}
    # Prevent recursive calling
    unset "${rc_arg}_cmd" "${rc_arg}_precmd" "${rc_arg}_postcmd"
    # Check master variable
    run_rc_command "${_rc_prefix}${rc_arg}" ${rc_extra_args}
}

samba_reload_cmd() {
    local name rcvar command pidfile
    # Prevent recursive calling
    unset "${rc_arg}_cmd" "${rc_arg}_precmd" "${rc_arg}_postcmd"
    # Apply to all daemons
    for name in ${samba_daemons}; do
        rcvar=$(set_rcvar ${name})
        command="/opt/taos/samba3/sbin/${name}"
        pidfile="/opt/taos/samba3/var/run/samba/${name}${pid_extra}.pid"
        # Daemon should be enabled and running
        if [ -n "${rcvar}" ] && checkyesno "${rcvar}"; then
            if [ -n "$(check_pidfile "${pidfile}" "${command}")" ]; then
                debug "reloading ${name} configuration"
                echo "Reloading ${name}."
                # XXX: Hack with pid_extra
                ${smbcontrol_command} "${name}${pid_extra}" 'reload-config' ${command_args} >/dev/null 2>&1
            fi
        fi
    done
}

samba_cmd() {
    local name rcvar rcvars v command pidfile samba_daemons result
    # Prevent recursive calling
    unset "${rc_arg}_cmd" "${rc_arg}_precmd" "${rc_arg}_postcmd"
    # Stop processes in the reverse order
    if [ "${rc_arg}" = "stop" ] ; then
        samba_daemons=$(reverse_list ${samba_daemons})
    fi
    # Assume success
    result=0
    # Apply to all daemons
    for name in ${samba_daemons}; do
        rcvar=$(set_rcvar ${name})
        # XXX
        rcvars=''; v=''
        command="/opt/taos/samba3/sbin/${name}"
        pidfile="/opt/taos/samba3/var/run/samba/${name}${pid_extra}.pid"
        # Daemon should be enabled and running
        if [ -n "${rcvar}" ] && checkyesno "${rcvar}"; then
            run_rc_command "${_rc_prefix}${rc_arg}" ${rc_extra_args}
            # If any of the of the commands failed, take it as a total result
            result=$((${result} || $?))
        fi
    done
    return ${result}
}

run_rc_command "$1"

