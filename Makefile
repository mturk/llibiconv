# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Originally contributed by Mladen Turk <mturk apache.org>
#
CC = cl.exe
LN = link.exe
AR = lib.exe
RC = rc.exe

!IF !DEFINED(BUILD_CPU) || "$(BUILD_CPU)" == ""
!IF DEFINED(VSCMD_ARG_TGT_ARCH)
BUILD_CPU = $(VSCMD_ARG_TGT_ARCH)
!ELSE
!ERROR Must specify BUILD_CPU matching compiler x86 or x64
!ENDIF
!ENDIF

!IF !DEFINED(WINVER) || "$(WINVER)" == ""
WINVER = 0x0601
!ENDIF

!IF DEFINED(_STATIC_MSVCRT)
CRT_CFLAGS = -MT
!ELSE
CRT_CFLAGS = -MD
!ENDIF

!IF !DEFINED(SRCDIR) || "$(SRCDIR)" == ""
SRCDIR = .
!ENDIF

!IF !DEFINED(TARGET_LIB) || "$(TARGET_LIB)" == ""
TARGET_LIB = lib
!ENDIF

CFLAGS = $(CFLAGS) -I$(SRCDIR)\include -I$(SRCDIR)\lib -I$(SRCDIR)\libcharset\include
CFLAGS = $(CFLAGS) -DNDEBUG -DWIN32 -D_WIN32_WINNT=$(WINVER) -DWINVER=$(WINVER)
CFLAGS = $(CFLAGS) -D_CRT_SECURE_NO_DEPRECATE -D_CRT_NONSTDC_NO_DEPRECATE $(EXTRA_CFLAGS)

!IF DEFINED(_STATIC)
TARGET  = lib
CFLAGS  = $(CFLAGS) -DICONV_DECLARE_STATIC
PROJECT = iconv-1
ARFLAGS = /nologo /SUBSYSTEM:CONSOLE /MACHINE:$(BUILD_CPU) $(EXTRA_ARFLAGS)
!ELSE
TARGET  = dll
CFLAGS  = $(CFLAGS) -DICONV_DECLARE_EXPORT
PROJECT = libiconv-1
LDFLAGS = /nologo /INCREMENTAL:NO /OPT:REF /DLL /SUBSYSTEM:CONSOLE /MACHINE:$(BUILD_CPU) $(EXTRA_LDFLAGS)
!ENDIF

WORKDIR = $(BUILD_CPU)-rel-$(TARGET)
OUTPUT  = $(WORKDIR)\$(PROJECT).$(TARGET)

CLOPTS = /c /nologo /wd4244 /wd4267 /wd4090 /wd4311 $(CRT_CFLAGS) -W3 -O2 -Ob2
RFLAGS = /l 0x409 /n /d NDEBUG /d WIN32 /d WINNT /d WINVER=$(WINVER)
RFLAGS = $(RFLAGS) /d _WIN32_WINNT=$(WINVER) $(EXTRA_RFLAGS)
LDLIBS = kernel32.lib $(EXTRA_LIBS)


OBJECTS = \
	$(WORKDIR)\localcharset.obj \
	$(WORKDIR)\iconv.obj

!IF "$(TARGET)" == "dll"
OBJECTS = $(OBJECTS) $(WORKDIR)\libiconv.res
!ENDIF

all : $(WORKDIR) $(OUTPUT)

$(WORKDIR) :
	@-md $(WORKDIR)

{$(SRCDIR)\lib}.c{$(WORKDIR)}.obj:
	$(CC) $(CLOPTS) $(CFLAGS) -Fo$(WORKDIR)\ $<

{$(SRCDIR)\libcharset\lib}.c{$(WORKDIR)}.obj:
	$(CC) $(CLOPTS) $(CFLAGS) -Fo$(WORKDIR)\ $<

{$(SRCDIR)\windows}.rc{$(WORKDIR)}.res:
	$(RC) $(RFLAGS) /fo $@ $<

$(OUTPUT): $(WORKDIR) $(OBJECTS)
!IF "$(TARGET)" == "dll"
	$(LN) $(LDFLAGS) $(OBJECTS) $(LDLIBS) /out:$(OUTPUT)
!ELSE
	$(AR) $(ARFLAGS) $(OBJECTS) /out:$(OUTPUT)
!ENDIF

!IF !DEFINED(PREFIX) || "$(PREFIX)" == ""
install:
	@echo PREFIX is not defined
	@echo Use `nmake install PREFIX=directory`
	@echo.
	@exit /B 1
!ELSE
install : all
!IF "$(TARGET)" == "dll"
	@xcopy /I /Y /Q "$(WORKDIR)\*.dll" "$(PREFIX)\bin"
!ENDIF
	@xcopy /I /Y /Q "$(WORKDIR)\*.lib" "$(PREFIX)\$(TARGET_LIB)"
	@xcopy /I /Y /Q "$(SRCDIR)\include\*.h" "$(PREFIX)\include"
!ENDIF

clean:
	@-rd /S /Q $(WORKDIR) 2>NUL
