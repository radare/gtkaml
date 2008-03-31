AC_INIT([gtkaml],[0.2.0.2])

AM_INIT_AUTOMAKE(AC_PACKAGE_NAME, AC_PACKAGE_VERSION)
AM_CONFIG_HEADER(config.h)
AM_MAINTAINER_MODE

AC_ISC_POSIX
AC_PROG_CC

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

AC_PATH_PROG(VALAC, valac, valac)
AC_SUBST(VALAC)
AC_DEFINE([VALAFLAGS], VALAFLAGS, "valac flags")

AC_DIAGNOSE([obsolete],[AM_PROG_CC_STDC:
	your code should no longer depend upon `am_cv_prog_cc_stdc', but upon
	`ac_cv_prog_cc_stdc'.  Remove this warning and the assignment when
	you adjust the code.  You can also remove the above call to
	AC_PROG_CC if you already called it elsewhere.])
am_cv_prog_cc_stdc=$ac_cv_prog_cc_stdc

AC_HEADER_STDC

PKG_CHECK_MODULES([GLIB], glib-2.0)
AC_SUBST(GLIB_CFLAGS)
AC_SUBST(GLIB_LIBS)

PKG_CHECK_MODULES([GTK], gtk+-2.0)
AC_SUBST(GTK_CFLAGS)
AC_SUBST(GTK_LIBS)

PKG_CHECK_MODULES([LIBXML2], libxml-2.0)
AC_SUBST(LIBXML2_CFLAGS)
AC_SUBST(LIBXML2_LIBS)

PKG_CHECK_MODULES(VALA, vala-1.0 >= 0.1.7)
AC_SUBST(VALA_CFLAGS)
AC_SUBST(VALA_LIBS)

AC_CONFIG_FILES([
Makefile
src/Makefile
data/Makefile
vapi/Makefile
tests/Makefile
examples/SimpleViewer2/Makefile
])

AC_OUTPUT
