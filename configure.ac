AC_INIT([gtkaml],[0.2.13])

AM_INIT_AUTOMAKE(AC_PACKAGE_NAME, AC_PACKAGE_VERSION)
AM_CONFIG_HEADER(config.h)
AM_MAINTAINER_MODE

AC_ISC_POSIX
AC_PROG_CC
AM_PROG_VALAC([0.10])
AC_PROG_LN_S

EXTRA_CFLAGS=
EXTRA_LDFLAGS=

case $host in
*-*-mingw32* | *-*-windows)
		EXTRA_CFLAGS="-mno-cygwin -mwindows -mms-bitfields -fno-strict-aliasing "	
		EXTRA_LDFLAGS="-export-all-symbols -mwindows -no-undefined -mms-bitfields" ;;
*-*-cygwin*)
		EXTRA_CFLAGS="-fno-strict-aliasing"
		EXTRA_LDFLAGS="-export-all-symbols -mms-bitfields";;
esac

AC_SUBST(EXTRA_CFLAGS)
AC_SUBST(EXTRA_LDFLAGS)

AC_HEADER_STDC

PKG_CHECK_MODULES([GLIB], glib-2.0)
AC_SUBST(GLIB_CFLAGS)
AC_SUBST(GLIB_LIBS)

PKG_CHECK_MODULES([GIO], gio-2.0)
AC_SUBST(GIO_CFLAGS)
AC_SUBST(GIO_LIBS)

PKG_CHECK_MODULES([GTK], gtk+-2.0)
AC_SUBST(GTK_CFLAGS)
AC_SUBST(GTK_LIBS)

PKG_CHECK_MODULES([LIBXML2], libxml-2.0)
AC_SUBST(LIBXML2_CFLAGS)
AC_SUBST(LIBXML2_LIBS)

PKG_CHECK_MODULES(VALA, libvala-0.12,[VALA_PKG="libvala-0.12"],[PKG_CHECK_MODULES(VALA, vala-0.10, [VALA_PKG="vala-0.10"])])
AM_CONDITIONAL([VALA_LATEST], [test $VALA_PKG = libvala-0.12])

AC_SUBST(VALA_PKG)
AC_SUBST(VALA_CFLAGS)
AC_SUBST(VALA_LIBS)

m4_ifdef([AM_SILENT_RULES],[AM_SILENT_RULES([yes])])

AC_CONFIG_FILES([
Makefile
src/Makefile
data/Makefile
vapi/Makefile
tests/Makefile
])

AC_OUTPUT
