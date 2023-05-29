/* Manually crafted */
/* Copyright (C) 1999-2003, 2005, 2007, 2010, 2012 Free Software Foundation, Inc.
   This file is part of the GNU LIBICONV Library.

   The GNU LIBICONV Library is free software; you can redistribute it
   and/or modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either version 2.1
   of the License, or (at your option) any later version.

   The GNU LIBICONV Library is distributed in the hope that it will be
   useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the GNU LIBICONV Library; see the file COPYING.LIB.
   If not, see <https://www.gnu.org/licenses/>.  */



/* Define to 1 to enable a few rarely used encodings. */
#define ENABLE_EXTRA 1
/* Define to 1 if the package shall run at any location in the filesystem. */
/* #undef ENABLE_RELOCATABLE */

/* Define as const if the declaration of iconv() needs const. */
#define ICONV_CONST
/* Define to 1 if you have the setlocale() function. */
#define HAVE_SETLOCALE 1
/* Define to 1 if you have the <stddef.h> header file. */
#define HAVE_STDDEF_H 1
/* Define to 1 if you have the <stdlib.h> header file. */
#define HAVE_STDLIB_H 1
/* Define to 1 if you have the <string.h> header file. */
#define HAVE_STRING_H 1
/* Define if you have the mbrtowc() function. */
#define HAVE_MBRTOWC 1
/* Define if you have the wcrtomb() function. */
#define HAVE_WCRTOMB 1
/* Define to 1 if O_NOFOLLOW works. */
#define HAVE_WORKING_O_NOFOLLOW 0
/* Define if the machine's byte ordering is little endian. */
#define WORDS_LITTLEENDIAN 1

#define HAVE_VISIBILITY 0
/* Define to 'int' if <sys/types.h> does not define. */
#define mode_t int
/* Define as a signed type of the same size as size_t. */
#define ssize_t int

#define LIBDIR "."

