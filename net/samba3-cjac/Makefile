# $FreeBSD$

PORTNAME=	samba3-cjac
PORTVERSION=	3.5.21
CATEGORIES=	net
MASTER_SITES=	http://phx0.colliertech.org/~cjac/src/samba3_bsd6/


MAINTAINER=	cjac@colliertech.org
COMMENT= backport of samba3 and dependencies to FreeBSD 6.3

PREFIX=        /opt/taos/samba3
WKDIR  ?= /usr/ports/net/samba3-cjac/work/samba3-cjac-3.5.21

.include <bsd.port.mk>

${.CURDIR}/env:
	echo "#!/bin/sh" > env ; echo "" >> env ; \
	echo -n "LD_LIBRARY_PATH=\"${PREFIX}/BerkeleyDB.4.4/lib:${PREFIX}/lib:" >> env ; \
	echo -n '$$LD_LIBRARY_PATH" ' >> env ; \
	echo -n "PATH=\"${PREFIX}/bin:${PREFIX}/sbin:" >> env ; \
	echo -n '$$PATH" ' >> env ; \
	echo 'exec $$*' >> env

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


install: inst

${.CURDIR}/pkg-plist: 
	cd ${PREFIX} ; \
	find . -name '*.old' -delete ; \
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

