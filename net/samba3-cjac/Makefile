# $FreeBSD$

PORTNAME=	samba3-cjac
PORTVERSION=	3.5.21
CATEGORIES=	net
MASTER_SITES=	http://www.colliertech.org/~cjac/src/samba3_bsd6/

MAINTAINER=	cjac@colliertech.org
COMMENT= backport of samba3 and dependencies to FreeBSD 6.3

PREFIX=        /opt/taos/samba3
WKDIR  ?= /usr/ports/net/samba3-cjac/work/samba3-cjac-3.5.21

.include <bsd.port.mk>

${.CURDIR}/env:
	echo "#!/bin/sh" > env ; echo "" >> env ; \
	echo -n "LD_LIBRARY_PATH=\"${PREFIX}/lib:" >> env ; \
	echo -n '$$LD_LIBRARY_PATH" ' >> env ; \
	echo -n "PATH=\"${PREFIX}/bin:${PREFIX}/sbin:" >> env ; \
	echo -n '$$PATH" ' >> env ; \
	echo 'exec $$*' >> env

env: ${.CURDIR}/env

inst: ${.CURDIR}/env
	cp env ${PREFIX}/bin/
	chmod ug+x ${PREFIX}/bin/env
	cp ${WKDIR}/samba-3.5.21/nsswitch/nss_winbind.so ${PREFIX}/lib/libnss_winbind.so
	ln -sf ${PREFIX}/lib/libnss_winbind.so ${PREFIX}/lib/libnss_winbind.so.2
	cp ${WKDIR}/samba-3.5.21/nsswitch/nss_wins.so ${PREFIX}/lib/libnss_wins.so
	ln -sf ${PREFIX}/lib/libnss_wins.so ${PREFIX}/lib/libnss_wins.so.2
	chmod 444 ${PREFIX}/lib/libnss_win*.so
	chown root:wheel ${PREFIX}/lib/libnss_win*.so
	mkdir -p ${PREFIX}/etc/samba/ ${PREFIX}/etc/rc.d \
		${PREFIX}/var/log/samba ${PREFIX}/var/run/samba ${PREFIX}/var/cache/samba ${PREFIX}/var/lib/samba
	cp smb.conf ${PREFIX}/etc/samba/
	cp samba.sh ${PREFIX}/etc/rc.d/samba
	cp sshd ${PREFIX}/etc/pam.d/
	cp krb5.conf ntp.conf nsswitch.conf ld.so.conf ${PREFIX}/etc/
	chmod u+x ${PREFIX}/etc/rc.d/samba
	chown root:wheel ${PREFIX}/etc/rc.d/samba
	mkdir -p ${PREFIX}/lib/samba/idmap
	cp -f ${WKDIR}/samba-3.5.21/source3/bin/adex.so ${PREFIX}/lib/samba/idmap
	cp -f ${WKDIR}/samba-3.5.21/source3/bin/ad.so ${PREFIX}/lib/samba/idmap
	cp -f ${WKDIR}/samba-3.5.21/source3/bin/hash.so ${PREFIX}/lib/samba/idmap
	cp -f ${WKDIR}/samba-3.5.21/source3/bin/ldap.so ${PREFIX}/lib/samba/idmap
	cp -f ${WKDIR}/samba-3.5.21/source3/bin/rid.so ${PREFIX}/lib/samba/idmap
	cp -f ${WKDIR}/samba-3.5.21/source3/bin/tdb2.so ${PREFIX}/lib/samba/idmap

install: inst

${.CURDIR}/pkg-plist: 
	cd ${PREFIX} ; \
	find . -name '*.old' -delete ; \
	find . -name '*.tdb' -delete ; \
	find var/lib/samba -name '*.ldb' -delete ; \
	find var/cache/samba -name '*.dat' -delete ; \
	find var/run/samba -name '*.pid' -delete ; \
	find var/run/samba -name 'pipe' -delete ; \
	find var/run/samba -name 'krb5.conf.*' -delete ; \
	find . -name 'log.*' -delete ; \
	find * \! -type d | sort > ${.CURDIR}/pkg-plist ; \
	cd ${.CURDIR}

${.CURDIR}/samba3.tgz: pkg

pkg: ${.CURDIR}/pkg-plist
	cd ${PREFIX} ; \
	pkg_create \
		-p ${PREFIX} \
		-d ${.CURDIR}/pkg-descr \
		-c ${.CURDIR}/pkg-descr \
		-f ${.CURDIR}/pkg-plist \
		${.CURDIR}/samba3.tgz ; \
	cd ${.CURDIR}

${.CURDIR}/samba3_i386.tgz: ${.CURDIR}/samba3.tgz
	mv ${.CURDIR}/samba3.tgz ${.CURDIR}/samba3_i386.tgz 

${.CURDIR}/samba3_i386.sum: ${.CURDIR}/samba3_i386.tgz
	md5 ${.CURDIR}/samba3_i386.tgz > ${.CURDIR}/samba3_i386.sum
	sha256 ${.CURDIR}/samba3_i386.tgz >> ${.CURDIR}/samba3_i386.sum
