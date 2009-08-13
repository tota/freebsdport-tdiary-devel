# New ports collection makefile for:    tdiary-devel
# Date created:                 9 June 2005
# Whom:                         Fumihiko Kimura <jfkimura@yahoo.co.jp>
#
# $FreeBSD$
#

PORTNAME=	tdiary
PORTVERSION=	2.3.3
CATEGORIES?=	www ruby
MASTER_SITES=	SF \
		http://www.tdiary.org/download/
PKGNAMESUFFIX=	-devel
DISTNAME=	${PORTNAME}-full-${PORTVERSION}

MAINTAINER=	tota@FreeBSD.org
COMMENT=	A Web-based diary system (like weblog) written in Ruby

.if defined(WITH_FCGI)
RUN_DEPENDS=	${RUBY_SITELIBDIR}/fcgi.rb:${PORTSDIR}/www/ruby-fcgi
.endif

NO_BUILD=	yes
CONFLICTS?=	ja-tdiary-devel-[0-9]*
PKGMESSAGE=	${WRKDIR}/pkg-message
USE_RUBY=	yes
PORTSCOUT=	limitw:1,odd

RUBY_SHEBANG_FILES=	index.fcgi \
			index.rb \
			update.rb \
			misc/convert2.rb \
			misc/migrate.rb \
			misc/plugin/amazon/amazonimg.rb \
			misc/plugin/pingback/pb.rb \
			misc/plugin/squeeze.rb \
			misc/plugin/trackback/tb.rb \
			misc/plugin/xmlrpc/xmlrpc.rb \
			misc/style/etdiary/etdiary_test.rb \
			tdiary/wiki_style_test.rb \
			theme/themebench.rhtml

PORTDOCS=	ChangeLog COPYING HOWTO-make-io.rd HOWTO-make-plugin.html \
		HOWTO-make-theme.html HOWTO-use-plugin.html \
		HOWTO-write-tDiary.en.html HOWTO-write-tDiary.html INSTALL.html \
		README.en.html README.html UPGRADE doc.css

SUB_FILES=	pkg-message
WRKSRC=		${WRKDIR}/${PORTNAME}-${PORTVERSION}
DOCSDIR=	${PREFIX}/share/doc/${PORTNAME}${PKGNAMESUFFIX}
EXAMPLESDIR=	${PREFIX}/share/examples/${PORTNAME}${PKGNAMESUFFIX}

#TDIARY_LANG	ja:Japanese en:English zh:Traditional-Chinese
.if !defined(TDIARY_LANG) || ( defined(TDIARY_LANG) && ${TDIARY_LANG} != ja )
TDIARY_LANG=	en
.endif

RUBY_REQUIRE=	Ruby >= 182

.include <bsd.port.pre.mk>

.if ${RUBY_VER} == 1.9
.if !defined(RUBY_PROVIDED)
IGNORE=	requires Ruby 1.9.1 or later
.endif
.endif # RUBY_VER

.if ${RUBY_VER} == 1.8
.if !defined(RUBY_PROVIDED)
IGNORE=	requires Ruby 1.8.2 or later
.endif
.if !defined(WITHOUT_TDIARY_NORA)
RUN_DEPENDS+=	${RUBY_SITEARCHLIBDIR}/web/escape_ext.so:${PORTSDIR}/www/ruby-nora
.endif
.endif # RUBY_VER

post-extract:
	@cd ${WRKSRC} && ${RM} -f README && ${MV} ChangeLog doc
	@cd ${WRKSRC} && ${MV} doc ${WRKDIR}

do-install:
	@-${MKDIR} ${EXAMPLESDIR}
	@${SED} -e 's,#!/usr/bin/env ruby,#!${RUBY},' \
		-e 's,@@@@PREFIX@@@@,${PREFIX},g' \
		-e 's,@@@@TDIARY@@@@,${PORTNAME}${PKGNAMESUFFIX},g' \
		-e 's,@@@@LANG@@@@,${TDIARY_LANG},g' \
		${FILESDIR}/tdiaryinst.rb.in > ${EXAMPLESDIR}/tdiaryinst.rb
	@(cd ${WRKSRC} && ${COPYTREE_SHARE} . ${EXAMPLESDIR})

post-install:
.if !defined(NOPORTDOCS)
	@${INSTALL} -d ${DOCSDIR}
	@cd ${WRKDIR}/doc && ${INSTALL_DATA} ${PORTDOCS} ${DOCSDIR}
.endif
	@${CAT} ${PKGMESSAGE}

.include <bsd.port.post.mk>
