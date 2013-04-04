# $FreeBSD$

PORTNAME=	samba3
PORTVERSION=	3.5.21
CATEGORIES=	net
MASTER_SITES=	http://www.colliertech.org/~cjac/src/samba3_bsd4/

MAINTAINER=	cjac@colliertech.org
COMMENT=	backport of samba3 and dependencies to FreeBSD 4.11

MAN8=		smbd.8
MANCOMPRESSED=	yes

PREFIX?=        ${LOCALBASE}/samba3

.include <bsd.port.mk>

${.CURDIR}/env:
	echo "#!/bin/sh" > env ; echo "" >> env ; \
	echo -n "LD_LIBRARY_PATH=\"${PREFIX}/BerkeleyDB.4.4/lib:${PREFIX}/lib:" >> env ; \
	echo -n '$$LD_LIBRARY_PATH" ' >> env ; \
	echo -n "PATH=\"${PREFIX}/bin:${PREFIX}/sbin:" >> env ; \
	echo -n '$$PATH" ' >> env ; \
	echo 'exec $$*' >> env

install: ${.CURDIR}/env
	cp env ${PREFIX}/bin/
	chmod ug+x ${PREFIX}/bin/env

${.CURDIR}/samba3.tgz: pkg

pkg:
	cd ${PREFIX} ; \
	pkg_create \
		-p ${PREFIX} \
		-d ${.CURDIR}/pkg-descr \
		-c ${.CURDIR}/pkg-descr \
		-f ${.CURDIR}/pkg-plist \
		${.CURDIR}/samba3.tgz ; \
	cd ${.CURDIR}

