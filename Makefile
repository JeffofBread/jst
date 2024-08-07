.POSIX:

# hst version
VERSION = 0.1

# paths
PREFIX = /usr/local
MANPREFIX = $(PREFIX)/share/man

X11INC = /usr/X11R6/include
X11LIB = /usr/X11R6/lib

# includes and libs
PKG_CONFIG = pkg-config
INCS = -I$(X11INC) -I${CONFIGDIR} `$(PKG_CONFIG) --cflags fontconfig` `$(PKG_CONFIG) --cflags freetype2`
LIBS = -L$(X11LIB) -lm -lrt -lX11 -lutil -lXft `$(PKG_CONFIG) --libs fontconfig` `$(PKG_CONFIG) --libs freetype2`

# OpenBSD (untested):
#CPPFLAGS = -DVERSION=\"$(VERSION)\" -D_XOPEN_SOURCE=600 -D_BSD_SOURCE
#LIBS = -L$(X11LIB) -lm -lX11 -lutil -lXft \
#       `$(PKG_CONFIG) --libs fontconfig` \
#       `$(PKG_CONFIG) --libs freetype2`
#MANPREFIX = ${PREFIX}/man

# flags
JSTCPPFLAGS = -DVERSION=\"$(VERSION)\" -D_XOPEN_SOURCE=600
JSTCFLAGS = $(INCS) $(JSTCPPFLAGS) $(CPPFLAGS) $(CFLAGS)
JSTLDFLAGS = $(LIBS) $(LDFLAGS)

# compiler and linker
CC = cc

# jst dirs
BUILDDIR = ${CURDIR}/build
CONFIGDIR = ${CURDIR}/config
RESOURCESDIR = ${CURDIR}/resources
SOURCEDIR = ${CURDIR}/source

SRC = jst.c x.c
OBJ = $(addprefix ${BUILDDIR}/,${SRC:.c=.o})

# 0 = pretty, 1 = raw make output
# To run from cli with VERBOSE of 1 just do this:
# `make VERBOSE=1 command_to_run`
VERBOSE := 0

# Print format for prettier output
PRINTF := @printf "%-30s | %s |  %s\n"
ifeq ($(VERBOSE), 0)
	Q := @
endif

.DEFAULT_GOAL := all

${BUILDDIR}/%.o: ${SOURCEDIR}/%.c | ${BUILDDIR}
	$(PRINTF) "Compiling jst source" ${CC} $@
	$Q${CC} ${JSTCFLAGS} -c $< -o $@

${BUILDDIR}:
	@printf "Making jst build directory\n"
	$Qmkdir -p ${BUILDDIR}

$(OBJ): ${CONFIGDIR}/config.h

${CONFIGDIR}/config.h:
	$(PRINTF) "Copying jst default config" "cp" "config.def.h -> config.h"
	$Qcp ${CONFIGDIR}/config.def.h ${CONFIGDIR}/config.h

all: jst

jst: $(OBJ) ${BUILDDIR}
	$(PRINTF) "Linking jst objects" ${CC} "${SRC:.c=.o}"
	$Q$(CC) -o ${BUILDDIR}/$@ $(OBJ) $(JSTLDFLAGS)

clean:
	@printf "Cleaning jst build directory\n"
	$Qrm -f ${BUILDDIR}/jst $(OBJ)

install: jst
	$(PRINTF) "Installing jst binary" "  "  "$(DESTDIR)$(PREFIX)/bin/jst"
	$Qmkdir -p $(DESTDIR)$(PREFIX)/bin
	$Qcp -f ${BUILDDIR}/jst $(DESTDIR)$(PREFIX)/bin
	$Qchmod 755 $(DESTDIR)$(PREFIX)/bin/jst
	$Qmkdir -p $(DESTDIR)$(MANPREFIX)/man1
	$Qsed "s/VERSION/$(VERSION)/g" < ${RESOURCESDIR}/jst.1 > $(DESTDIR)$(MANPREFIX)/man1/jst.1
	$Qchmod 644 $(DESTDIR)$(MANPREFIX)/man1/jst.1
	$Qtic -x ${RESOURCESDIR}/jst.info

uninstall:
	@printf "Uninstalling jst binary from $(DESTDIR)$(PREFIX)/bin/jst\n"
	$Qrm -f $(DESTDIR)$(PREFIX)/bin/jst
	$Qrm -f $(DESTDIR)$(MANPREFIX)/man1/jst.1

.PHONY: all clean install uninstall
