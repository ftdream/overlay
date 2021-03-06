# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libiconv/libiconv-1.14-r1.ebuild,v 1.7 2014/05/24 09:47:39 hwoarang Exp $

EAPI="4"

inherit libtool toolchain-funcs multilib

DESCRIPTION="GNU charset conversion library for libc which doesn't implement it"
HOMEPAGE="http://www.gnu.org/software/libiconv/"
SRC_URI="mirror://gnu/libiconv/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE="+static-libs"

DEPEND="!sys-libs/glibc
	!userland_GNU? ( !sys-apps/man-pages )"
RDEPEND="${DEPEND}"

src_prepare() {
	epatch "${FILESDIR}"/${P}-no-gets.patch
	elibtoolize
}

multilib_src_configure() {
	use amd64 && multilib_toolchain_setup x86
	# In Prefix we want to have the same header declaration on every
	# platform, so make configure find that it should do
	# "const char * *inbuf"
	export am_cv_func_iconv=no

	# Disable NLS support because that creates a circular dependency
	# between libiconv and gettext
	ECONF_SOURCE="${S}" \
	econf \
		--libdir="${EPREFIX}"/usr/$(get_libdir) \
		--docdir="\$(datarootdir)/doc/${PF}/html" \
		--disable-nls \
		--enable-shared \
		$(use_enable static-libs static)
}

multilib_src_install_all() {
	# Install in /lib as utils installed in /lib like gnutar
	# can depend on this
	gen_usr_ldscript -a iconv charset

	# If we have a GNU userland, we probably have sys-apps/man-pages
	# installed, which means we want to rename our copies #503162.
	# The use of USELAND=GNU is kind of a hack though ...
	if use userland_GNU ; then
		cd "${ED}"/usr/share/man || die
		local f
		for f in man*/*.[0-9] ; do
			mv "${f}" "${f%/*}/${PN}-${f#*/}" || die
		done
	fi
}
