# unistd_h.m4 serial 38
dnl Copyright (C) 2006-2010 Free Software Foundation, Inc.
dnl This file is free software; the Free Software Foundation
dnl gives unlimited permission to copy and/or distribute it,
dnl with or without modifications, as long as this notice is preserved.

dnl Written by Simon Josefsson, Bruno Haible.

AC_DEFUN([gl_UNISTD_H],
[
  dnl Use AC_REQUIRE here, so that the default behavior below is expanded
  dnl once only, before all statements that occur in other macros.
  AC_REQUIRE([gl_UNISTD_H_DEFAULTS])
  AC_REQUIRE([AC_C_INLINE])

  gl_CHECK_NEXT_HEADERS([unistd.h])

  AC_CHECK_HEADERS_ONCE([unistd.h])
  if test $ac_cv_header_unistd_h = yes; then
    HAVE_UNISTD_H=1
  else
    HAVE_UNISTD_H=0
  fi
  AC_SUBST([HAVE_UNISTD_H])

  dnl Check for declarations of anything we want to poison if the
  dnl corresponding gnulib module is not in use.
  gl_WARN_ON_USE_PREPARE([[#include <unistd.h>
/* Some systems declare environ in the wrong header.  */
#ifndef __GLIBC__
# include <stdlib.h>
#endif
    ]], [environ])
])

AC_DEFUN([gl_UNISTD_MODULE_INDICATOR],
[
  dnl Use AC_REQUIRE here, so that the default settings are expanded once only.
  AC_REQUIRE([gl_UNISTD_H_DEFAULTS])
  GNULIB_[]m4_translit([$1],[abcdefghijklmnopqrstuvwxyz./-],[ABCDEFGHIJKLMNOPQRSTUVWXYZ___])=1
])

AC_DEFUN([gl_UNISTD_H_DEFAULTS],
[
  GNULIB_CHOWN=0;            AC_SUBST([GNULIB_CHOWN])
  GNULIB_CLOSE=0;            AC_SUBST([GNULIB_CLOSE])
  GNULIB_DUP2=0;             AC_SUBST([GNULIB_DUP2])
  GNULIB_DUP3=0;             AC_SUBST([GNULIB_DUP3])
  GNULIB_ENVIRON=0;          AC_SUBST([GNULIB_ENVIRON])
  GNULIB_EUIDACCESS=0;       AC_SUBST([GNULIB_EUIDACCESS])
  GNULIB_FACCESSAT=0;        AC_SUBST([GNULIB_FACCESSAT])
  GNULIB_FCHDIR=0;           AC_SUBST([GNULIB_FCHDIR])
  GNULIB_FCHOWNAT=0;         AC_SUBST([GNULIB_FCHOWNAT])
  GNULIB_FSYNC=0;            AC_SUBST([GNULIB_FSYNC])
  GNULIB_FTRUNCATE=0;        AC_SUBST([GNULIB_FTRUNCATE])
  GNULIB_GETCWD=0;           AC_SUBST([GNULIB_GETCWD])
  GNULIB_GETDOMAINNAME=0;    AC_SUBST([GNULIB_GETDOMAINNAME])
  GNULIB_GETDTABLESIZE=0;    AC_SUBST([GNULIB_GETDTABLESIZE])
  GNULIB_GETGROUPS=0;        AC_SUBST([GNULIB_GETGROUPS])
  GNULIB_GETHOSTNAME=0;      AC_SUBST([GNULIB_GETHOSTNAME])
  GNULIB_GETLOGIN=0;         AC_SUBST([GNULIB_GETLOGIN])
  GNULIB_GETLOGIN_R=0;       AC_SUBST([GNULIB_GETLOGIN_R])
  GNULIB_GETPAGESIZE=0;      AC_SUBST([GNULIB_GETPAGESIZE])
  GNULIB_GETUSERSHELL=0;     AC_SUBST([GNULIB_GETUSERSHELL])
  GNULIB_LCHOWN=0;           AC_SUBST([GNULIB_LCHOWN])
  GNULIB_LINK=0;             AC_SUBST([GNULIB_LINK])
  GNULIB_LINKAT=0;           AC_SUBST([GNULIB_LINKAT])
  GNULIB_LSEEK=0;            AC_SUBST([GNULIB_LSEEK])
  GNULIB_PIPE2=0;            AC_SUBST([GNULIB_PIPE2])
  GNULIB_PREAD=0;            AC_SUBST([GNULIB_PREAD])
  GNULIB_READLINK=0;         AC_SUBST([GNULIB_READLINK])
  GNULIB_READLINKAT=0;       AC_SUBST([GNULIB_READLINKAT])
  GNULIB_RMDIR=0;            AC_SUBST([GNULIB_RMDIR])
  GNULIB_SLEEP=0;            AC_SUBST([GNULIB_SLEEP])
  GNULIB_SYMLINK=0;          AC_SUBST([GNULIB_SYMLINK])
  GNULIB_SYMLINKAT=0;        AC_SUBST([GNULIB_SYMLINKAT])
  GNULIB_UNISTD_H_GETOPT=0;  AC_SUBST([GNULIB_UNISTD_H_GETOPT])
  GNULIB_UNISTD_H_SIGPIPE=0; AC_SUBST([GNULIB_UNISTD_H_SIGPIPE])
  GNULIB_UNLINK=0;           AC_SUBST([GNULIB_UNLINK])
  GNULIB_UNLINKAT=0;         AC_SUBST([GNULIB_UNLINKAT])
  GNULIB_USLEEP=0;           AC_SUBST([GNULIB_USLEEP])
  GNULIB_WRITE=0;            AC_SUBST([GNULIB_WRITE])
  dnl Assume proper GNU behavior unless another module says otherwise.
  HAVE_CHOWN=1;           AC_SUBST([HAVE_CHOWN])
  HAVE_DUP2=1;            AC_SUBST([HAVE_DUP2])
  HAVE_DUP3=1;            AC_SUBST([HAVE_DUP3])
  HAVE_EUIDACCESS=1;      AC_SUBST([HAVE_EUIDACCESS])
  HAVE_FACCESSAT=1;       AC_SUBST([HAVE_FACCESSAT])
  HAVE_FCHOWNAT=1;        AC_SUBST([HAVE_FCHOWNAT])
  HAVE_FSYNC=1;           AC_SUBST([HAVE_FSYNC])
  HAVE_FTRUNCATE=1;       AC_SUBST([HAVE_FTRUNCATE])
  HAVE_GETDOMAINNAME=1;   AC_SUBST([HAVE_GETDOMAINNAME])
  HAVE_GETDTABLESIZE=1;   AC_SUBST([HAVE_GETDTABLESIZE])
  HAVE_GETGROUPS=1;       AC_SUBST([HAVE_GETGROUPS])
  HAVE_GETHOSTNAME=1;     AC_SUBST([HAVE_GETHOSTNAME])
  HAVE_GETLOGIN=1;        AC_SUBST([HAVE_GETLOGIN])
  HAVE_GETPAGESIZE=1;     AC_SUBST([HAVE_GETPAGESIZE])
  HAVE_GETUSERSHELL=1;    AC_SUBST([HAVE_GETUSERSHELL])
  HAVE_LCHOWN=1;          AC_SUBST([HAVE_LCHOWN])
  HAVE_LINK=1;            AC_SUBST([HAVE_LINK])
  HAVE_LINKAT=1;          AC_SUBST([HAVE_LINKAT])
  HAVE_PIPE2=1;           AC_SUBST([HAVE_PIPE2])
  HAVE_PREAD=1;           AC_SUBST([HAVE_PREAD])
  HAVE_READLINK=1;        AC_SUBST([HAVE_READLINK])
  HAVE_READLINKAT=1;      AC_SUBST([HAVE_READLINKAT])
  HAVE_SLEEP=1;           AC_SUBST([HAVE_SLEEP])
  HAVE_SYMLINK=1;         AC_SUBST([HAVE_SYMLINK])
  HAVE_SYMLINKAT=1;       AC_SUBST([HAVE_SYMLINKAT])
  HAVE_DECL_ENVIRON=1;    AC_SUBST([HAVE_DECL_ENVIRON])
  HAVE_DECL_GETLOGIN_R=1; AC_SUBST([HAVE_DECL_GETLOGIN_R])
  HAVE_OS_H=0;            AC_SUBST([HAVE_OS_H])
  HAVE_SYS_PARAM_H=0;     AC_SUBST([HAVE_SYS_PARAM_H])
  HAVE_UNLINKAT=1;        AC_SUBST([HAVE_UNLINKAT])
  HAVE_USLEEP=1;          AC_SUBST([HAVE_USLEEP])
  REPLACE_CHOWN=0;        AC_SUBST([REPLACE_CHOWN])
  REPLACE_CLOSE=0;        AC_SUBST([REPLACE_CLOSE])
  REPLACE_DUP=0;          AC_SUBST([REPLACE_DUP])
  REPLACE_DUP2=0;         AC_SUBST([REPLACE_DUP2])
  REPLACE_FCHDIR=0;       AC_SUBST([REPLACE_FCHDIR])
  REPLACE_FCHOWNAT=0;     AC_SUBST([REPLACE_FCHOWNAT])
  REPLACE_GETCWD=0;       AC_SUBST([REPLACE_GETCWD])
  REPLACE_GETGROUPS=0;    AC_SUBST([REPLACE_GETGROUPS])
  REPLACE_GETPAGESIZE=0;  AC_SUBST([REPLACE_GETPAGESIZE])
  REPLACE_LCHOWN=0;       AC_SUBST([REPLACE_LCHOWN])
  REPLACE_LINK=0;         AC_SUBST([REPLACE_LINK])
  REPLACE_LINKAT=0;       AC_SUBST([REPLACE_LINKAT])
  REPLACE_LSEEK=0;        AC_SUBST([REPLACE_LSEEK])
  REPLACE_PREAD=0;        AC_SUBST([REPLACE_PREAD])
  REPLACE_READLINK=0;     AC_SUBST([REPLACE_READLINK])
  REPLACE_RMDIR=0;        AC_SUBST([REPLACE_RMDIR])
  REPLACE_SLEEP=0;        AC_SUBST([REPLACE_SLEEP])
  REPLACE_SYMLINK=0;      AC_SUBST([REPLACE_SYMLINK])
  REPLACE_UNLINK=0;       AC_SUBST([REPLACE_UNLINK])
  REPLACE_UNLINKAT=0;     AC_SUBST([REPLACE_UNLINKAT])
  REPLACE_USLEEP=0;       AC_SUBST([REPLACE_USLEEP])
  REPLACE_WRITE=0;        AC_SUBST([REPLACE_WRITE])
  UNISTD_H_HAVE_WINSOCK2_H=0; AC_SUBST([UNISTD_H_HAVE_WINSOCK2_H])
  UNISTD_H_HAVE_WINSOCK2_H_AND_USE_SOCKETS=0;
                           AC_SUBST([UNISTD_H_HAVE_WINSOCK2_H_AND_USE_SOCKETS])
])
