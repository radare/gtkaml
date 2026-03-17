AC_INIT([gtkaml],[0.6.0])

AM_INIT_AUTOMAKE([foreign subdir-objects])
AC_CONFIG_HEADERS([config.h])
AM_MAINTAINER_MODE

AC_PROG_CC
AC_PROG_LN_S
LT_INIT([disable-static])

AM_PROG_VALAC([0.48])
AC_PATH_PROG([VALAC], [valac], [valac])
AC_SUBST([VALAC])

AC_SUBST([CFLAGS])
AC_SUBST([LDFLAGS])
AC_SUBST([VALAFLAGS])

PKG_CHECK_MODULES([GLIB], [glib-2.0 >= 2.48])
PKG_CHECK_MODULES([GIO], [gio-2.0 >= 2.48])
PKG_CHECK_MODULES([LIBXML2], [libxml-2.0])

VALA_VERSION=
for vala_api in 0.64 0.62 0.60 0.58 0.56 0.54 0.52 0.50 0.48 0.46 0.44 0.42 0.40 0.38 0.36 0.34 0.32 0.30 0.28 0.26 0.24 0.22 0.20 0.18 0.16 ; do
	if $PKG_CONFIG --exists "libvala-$vala_api"; then
		VALA_VERSION="$vala_api"
		break
	fi
done

AS_IF([test -z "$VALA_VERSION"], [
	AC_MSG_ERROR([libvala development files were not found. Install a matching libvala-*.pc package for your valac toolchain.])
])

PKG_CHECK_MODULES([VALA], [libvala-$VALA_VERSION])
PKG_CHECK_VAR([VALA_BASE_LIBDIR], [libvala-$VALA_VERSION], [libdir])
VALA_CODEGEN_LIBDIR="$VALA_BASE_LIBDIR/vala-$VALA_VERSION"
AC_SUBST([VALA_CODEGEN_LIBDIR])
AC_SUBST([VALA_VERSION])
AH_TEMPLATE([VALA_VERSION], [Vala API version])
AC_DEFINE_UNQUOTED([VALA_VERSION], ["$VALA_VERSION"])

PKG_CHECK_MODULES([GTK3], [gtk+-3.0], [have_gtk3=yes], [have_gtk3=no])
PKG_CHECK_MODULES([GTK4], [gtk4], [have_gtk4=yes], [have_gtk4=no])
PKG_CHECK_MODULES([ADWAITA], [libadwaita-1], [have_adwaita=yes], [have_adwaita=no])
AM_CONDITIONAL([HAVE_GTK3], [test x$have_gtk3 = xyes])
AM_CONDITIONAL([HAVE_GTK4], [test x$have_gtk4 = xyes])
AM_CONDITIONAL([HAVE_ADWAITA], [test x$have_adwaita = xyes])

AC_ARG_ENABLE([tests],
	AS_HELP_STRING([--enable-tests], [Enable building of markup smoke tests]),
	[enable_tests=$enableval],
	[enable_tests=no])
AM_CONDITIONAL([ENABLE_TESTS], [test x$enable_tests = xyes])

AC_ARG_ENABLE([docs],
	AS_HELP_STRING([--enable-docs], [Generate valadoc output]),
	[enable_docs=$enableval],
	[enable_docs=no])
AM_CONDITIONAL([ENABLE_DOCS], [test x$enable_docs = xyes])

AS_IF([test "x$enable_docs" != xno], [
	AC_PATH_PROG([VALADOC], [valadoc], [:])
	AC_SUBST([VALADOC])
	AS_IF([test "$VALADOC" = :], [AC_MSG_ERROR([valadoc not found])])
])

m4_ifdef([AM_SILENT_RULES], [AM_SILENT_RULES([yes])])

AC_CONFIG_FILES([
Makefile
gtkaml-1.0.pc
src/Makefile
libgtkaml/Makefile
libgtkaml/gtkaml-1.0.deps
markuphints/Makefile
tests/Makefile
tests/gtk3/Makefile
tests/gtk4/Makefile
tests/adwaita/Makefile
])

AC_OUTPUT
