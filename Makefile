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
RC = rc.exe

!IF !DEFINED(BUILD_CPU) || "$(BUILD_CPU)" == ""
!ERROR Must specify BUILD_CPU matching compiler x86 or x64
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

CFLAGS = $(CFLAGS) -DNDEBUG -DWIN32 -D_WIN32_WINNT=$(WINVER) -DWINVER=$(WINVER) -DHAVE_CONFIG_H -DNO_XMALLOC
CFLAGS = $(CFLAGS) -I$(SRCDIR)\include -I$(SRCDIR)\lib -I$(SRCDIR)\libcharset\include

!IF !DEFINED(_STATIC) || "$(_STATIC)" == ""
TARGET  = dll
CFLAGS  = $(CFLAGS) -DICONV_DECLARE_EXPORT -DBUILDING_DLL
PROJECT = libiconv-1
WORKDIR = $(BUILD_CPU)_$(TARGET)
LFLAGS  = /nologo /INCREMENTAL:NO /OPT:REF /DLL /SUBSYSTEM:CONSOLE /MACHINE:$(BUILD_CPU) $(EXTRA_LFLAGS)
!ELSE
TARGET  = lib
CFLAGS  = $(CFLAGS) -DICONV_DECLARE_STATIC
PROJECT = iconv-1
WORKDIR = $(BUILD_CPU)_$(TARGET)
LFLAGS  = -lib /nologo $(EXTRA_LFLAGS)
!ENDIF
OUTPUT  = $(WORKDIR)\$(PROJECT).$(TARGET)

CFLAGS = $(CFLAGS) -DNDEBUG -DWIN32 -D_WIN32_WINNT=$(WINVER) -DWINVER=$(WINVER)
CFLAGS = $(CFLAGS) -D_CRT_SECURE_NO_DEPRECATE -D_CRT_NONSTDC_NO_DEPRECATE $(EXTRA_CFLAGS)
CLOPTS = /c /nologo /wd4244 /wd4267 /wd4090 $(CRT_CFLAGS) -W3 -O2 -Ob2
RFLAGS = /l 0x409 /n /d NDEBUG $(EXTRA_RFLAGS)
LDLIBS = kernel32.lib $(EXTRA_LIBS)


OBJECTS = \
	$(WORKDIR)\localcharset.obj \
	$(WORKDIR)\iconv.obj


all : $(WORKDIR) $(OUTPUT)

$(WORKDIR) :
	@-md $(WORKDIR)

{$(SRCDIR)\lib}.c{$(WORKDIR)}.obj:
	$(CC) $(CLOPTS) $(CFLAGS) -Fo$(WORKDIR)\ $<

{$(SRCDIR)\libcharset\lib}.c{$(WORKDIR)}.obj:
	$(CC) $(CLOPTS) $(CFLAGS) -Fo$(WORKDIR)\ $<

{$(SRCDIR)\windows}.rc{$(WORKDIR)}.res:
	$(RC) $(RFLAGS) /fo $@ $<

!IF "$(TARGET)" == "dll"
$(OUTPUT): $(WORKDIR) $(OBJECTS) $(WORKDIR)\libiconv.res
	$(LN) $(LFLAGS) $(OBJECTS) $(LDLIBS) /out:$(OUTPUT)
!ELSE
$(OUTPUT): $(WORKDIR) $(OBJECTS)
	$(LN) $(LFLAGS) $(OBJECTS) /out:$(OUTPUT)
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
	@xcopy /I /Y /Q "$(WORKDIR)\*.lib" "$(PREFIX)\lib"
	@xcopy /I /Y /Q "$(SRCDIR)\include\*.h" "$(PREFIX)\include"
!ENDIF

clean:
	@-rd /S /Q $(WORKDIR) 2>NUL
