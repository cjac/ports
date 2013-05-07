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
	rm -f ${.CURDIR}/pkg-plist
	cp ${.CURDIR}/env ${PREFIX}/bin/
	chmod ug+x ${PREFIX}/bin/env
	cp ${WKDIR}/samba-3.5.21/nsswitch/nss_winbind.so ${PREFIX}/lib/libnss_winbind.so
	ln -sf ${PREFIX}/lib/libnss_winbind.so ${PREFIX}/lib/libnss_winbind.so.2
	ln -sf ${PREFIX}/lib/libnss_winbind.so ${PREFIX}/lib/nss_winbind.so.1
	cp ${WKDIR}/samba-3.5.21/nsswitch/nss_wins.so ${PREFIX}/lib/libnss_wins.so
	ln -sf ${PREFIX}/lib/libnss_wins.so ${PREFIX}/lib/libnss_wins.so.2
	ln -sf ${PREFIX}/lib/libnss_wins.so ${PREFIX}/lib/nss_wins.so.1
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

install: inst ${.CURDIR}/pkg-plist

${.CURDIR}/pkg-plist: inst
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

pkg: inst ${.CURDIR}/pkg-plist
	cd ${PREFIX} ; \
	for file in `find lib bin sbin -type f | grep -v -E '(idmap|pam|nss)' | xargs file | grep 'not stripped' | awk -F: '{print $$1}'` ; \
	do \
	  unstripped=`echo $${file}`; \
	  stripped=`echo $${unstripped}.stripped`; \
	  strip -p --strip-debug --strip-unneeded $${unstripped} -o $${stripped} ; \
	  mv $${stripped} $${unstripped} ; \
	done ; \
	pkg_create \
		-p ${PREFIX} \
		-d ${.CURDIR}/pkg-descr \
		-c ${.CURDIR}/pkg-descr \
		-f ${.CURDIR}/pkg-plist \
		${.CURDIR}/samba3.tgz ; \
	cd ${.CURDIR}

${.CURDIR}/samba3_i386.tgz: ${.CURDIR}/samba3.tgz
	mv ${.CURDIR}/samba3.tgz ${.CURDIR}/samba3_i386.tgz
	mkdir -p ${CURDIR}/i386/6.3-RELEASE
	ln -f ${.CURDIR}/samba3_i386.tgz ${.CURDIR}/i386/6.3-RELEASE/samba3_i386.tgz

${.CURDIR}/samba3_i386.sum: ${.CURDIR}/samba3_i386.tgz
	md5 ${.CURDIR}/samba3_i386.tgz > ${.CURDIR}/samba3_i386.sum
	sha256 ${.CURDIR}/samba3_i386.tgz >> ${.CURDIR}/samba3_i386.sum
	ln -f ${.CURDIR}/samba3_i386.sum ${.CURDIR}/i386/6.3-RELEASE/samba3_i386.sum