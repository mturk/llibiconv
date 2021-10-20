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
SRCDIR = .

_CPU = x64
_LIB = lib64

!IF !DEFINED(WINVER) || "$(WINVER)" == ""
WINVER = 0x0601
!ENDIF

!IF DEFINED(_STATIC_MSVCRT)
CRT_CFLAGS = -MT
EXTRA_LIBS =
!ELSE
CRT_CFLAGS = -MD
!ENDIF

CFLAGS = $(CFLAGS) -I$(SRCDIR)\include -I$(SRCDIR)\lib -I$(SRCDIR)\libcharset\include
CFLAGS = $(CFLAGS) -DNDEBUG -DWIN32 -D_WIN32_WINNT=$(WINVER) -DWINVER=$(WINVER)
!IF DEFINED(CMSC_VERSION)
CFLAGS = $(CFLAGS) -D_CMSC_VERSION=$(CMSC_VERSION)
!ENDIF
CFLAGS = $(CFLAGS) -D_CRT_SECURE_NO_DEPRECATE -D_CRT_NONSTDC_NO_DEPRECATE $(EXTRA_CFLAGS)
CFLAGS = $(CFLAGS) -DENABLE_RELOCATABLE=1 -DIN_LIBRARY -DNO_XMALLOC -DHAVE_CONFIG_H
CFLAGS = $(CFLAGS) -Dset_relocation_prefix=libiconv_set_relocation_prefix
CFLAGS = $(CFLAGS) -Drelocate=libiconv_relocate -Drelocate2=libiconv_relocate2


!IF DEFINED(_STATIC)
TARGET  = lib
PROJECT = iconv-1
ARFLAGS = /nologo /MACHINE:$(_CPU) $(EXTRA_ARFLAGS)
!ELSE
TARGET  = dll
CFLAGS  = $(CFLAGS) -DBUILDING_LIBICONV -DBUILDING_DLL
PROJECT = libiconv-1
LDFLAGS = /nologo /INCREMENTAL:NO /OPT:REF /DLL /SUBSYSTEM:WINDOWS /MACHINE:$(_CPU) $(EXTRA_LDFLAGS)
!ENDIF

WORKDIR = $(CPU)-rel-$(TARGET)
OUTPUT  = $(WORKDIR)\$(PROJECT).$(TARGET)
CLOPTS  = /c /nologo /wd4244 /wd4267 /wd4090 /wd4018 /wd4311 $(CRT_CFLAGS) -W3 -O2 -Ob2
RFLAGS  = /l 0x409 /n /d NDEBUG /d WIN32 /d WINNT /d WINVER=$(WINVER)
RFLAGS  = $(RFLAGS) /d _WIN32_WINNT=$(WINVER) $(EXTRA_RFLAGS)
LDLIBS  = kernel32.lib $(EXTRA_LIBS)
!IF DEFINED(_PDB)
PDBNAME = -Fd$(WORKDIR)\$(PROJECT)
OUTPDB  = /pdb:$(WORKDIR)\$(PROJECT).pdb
CLOPTS  = $(CLOPTS) -Zi
LDFLAGS = $(LDFLAGS) /DEBUG
!ENDIF
!IF DEFINED(_VENDOR_SFX)
RFLAGS = $(RFLAGS) /d _VENDOR_SFX=$(_VENDOR_SFX)
!ENDIF
!IF DEFINED(_VENDOR_NUM)
RFLAGS = $(RFLAGS) /d _VENDOR_NUM=$(_VENDOR_NUM)
!ENDIF


OBJECTS = \
	$(WORKDIR)\localcharset.obj \
	$(WORKDIR)\iconv.obj \
	$(WORKDIR)\relocatable.obj

!IF "$(TARGET)" == "dll"
OBJECTS = $(OBJECTS) $(WORKDIR)\llibiconv.res
!ENDIF

all : $(WORKDIR) $(OUTPUT)

$(WORKDIR) :
	@-md $(WORKDIR)

{$(SRCDIR)\lib}.c{$(WORKDIR)}.obj:
	$(CC) $(CLOPTS) $(CFLAGS) -Fo$(WORKDIR)\ $(PDBNAME) $<

{$(SRCDIR)\libcharset\lib}.c{$(WORKDIR)}.obj:
	$(CC) $(CLOPTS) $(CFLAGS) -Fo$(WORKDIR)\ $(PDBNAME) $<

{$(SRCDIR)\windows}.rc{$(WORKDIR)}.res:
	$(RC) $(RFLAGS) /fo $@ $<

$(OUTPUT): $(WORKDIR) $(OBJECTS)
!IF "$(TARGET)" == "dll"
	$(LN) $(LDFLAGS) $(OBJECTS) $(LDLIBS) $(OUTPDB) /out:$(OUTPUT)
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
	@-md "$(PREFIX)" 2>NUL
	@-md "$(PREFIX)\include" 2>NUL
!IF "$(TARGET)" == "dll"
	@xcopy /I /Y /Q "$(WORKDIR)\*.dll" "$(PREFIX)\bin"
!ENDIF
!IF DEFINED(_PDB)
	@xcopy /I /Y /Q "$(WORKDIR)\*.pdb" "$(PREFIX)\bin"
!ENDIF
	@xcopy /I /Y /Q "$(WORKDIR)\*.lib" "$(PREFIX)\$(_LIB)"
	@copy /Y "$(SRCDIR)\include\iconv-dist.h" "$(PREFIX)\include\iconv.h" >NUL
!ENDIF

clean:
	@-rd /S /Q $(WORKDIR) 2>NUL
