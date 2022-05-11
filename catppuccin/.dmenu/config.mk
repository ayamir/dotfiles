# dmenu version
VERSION = 5.0

# paths
PREFIX = /usr/local
MANPREFIX = $(PREFIX)/share/man

X11INC = /usr/X11R6/include
X11LIB = /usr/X11R6/lib

# Xinerama, comment if you don't want it
XINERAMALIBS  = -lXinerama
XINERAMAFLAGS = -DXINERAMA

# freetype
FREETYPELIBS = -lfontconfig -lXft
FREETYPEINC = /usr/include/freetype2
# OpenBSD (uncomment)
#FREETYPEINC = $(X11INC)/freetype2

# Uncomment this for the json patch / JSON_PATCH
#JANSSONINC = `pkg-config --cflags jansson`
#JANSSONLIBS = `pkg-config --libs jansson`
# uncomment on RHEL for strcasecmp
#EXTRAFLAGS=-D_GNU_SOURCE

# Uncomment this for the alpha patch / ALPHA_PATCH
#XRENDER = -lXrender

# Uncomment for the pango patch / PANGO_PATCH
#PANGOINC = `pkg-config --cflags xft pango pangoxft`
#PANGOLIB = `pkg-config --libs xft pango pangoxft`

# includes and libs
INCS = -I$(X11INC) -I$(FREETYPEINC) $(JANSSONINC) ${PANGOINC}
LIBS = -L$(X11LIB) -lX11 $(XINERAMALIBS) $(FREETYPELIBS) $(JANSSONLIBS) -lm $(XRENDER) ${PANGOLIB}

# flags
CPPFLAGS = -D_DEFAULT_SOURCE -D_BSD_SOURCE -D_XOPEN_SOURCE=700 -D_POSIX_C_SOURCE=200809L -DVERSION=\"$(VERSION)\" $(XINERAMAFLAGS) $(EXTRAFLAGS)
CFLAGS   = -std=c99 -pedantic -Wall -Os $(INCS) $(CPPFLAGS)
LDFLAGS  = $(LIBS)

# compiler and linker
CC = cc
