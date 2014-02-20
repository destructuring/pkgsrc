# depends on:
#   externally defined PKG_HOME, CC, PATH
#   vault symlink in $(PWD) to distfiles, packages
#   suggestion:
#     env CC=clang PKG_HOME=/opt/goose/pkg PATH="/opt/goose/pkg/bin:/opt/goose/pkg/sbin:$PATH" make -f Makefile.goose

.PHONY: $(PKG) packages bmake bmake_inner

CC := $(shell basename $(shell which clang gcc | head -1))

PKG_ID := $(shell bin/guess-os)$(shell echo $(PKG_HOME) | tr / _)

PACKAGES := $(VAULT)/packages/$(PKG_ID)
WRKOBJDIR := $(PWD)/work
DISTDIR := $(VAULT)/distfiles

PKG_OPT := env MAKEFLAGS= MFLAGS= PACKAGES=$(PACKAGES) WRKOBJDIR=$(WRKOBJDIR) DISTDIR=$(DISTDIR) PKG_RCD_SCRIPTS=no

BMAKE = $(PKG_OPT) $(PKG_HOME)/bin/bmake
PKGADD := $(PKG_OPT) PKG_PATH=$(PACKAGES)/All $(PKG_HOME)/sbin/pkg_add

all: default

$(DISTDIR)/.gitignore:
	mkdir -p $(DISTDIR)
	touch $@

$(WRKOBJDIR)/.gitignore:
	mkdir -p $(WRKOBJDIR)
	touch $@

$(PACKAGES)/.gitignore:
	mkdir -p $(PACKAGES)
	touch $@

bmake:
	env CC=$(CC) PATH="$(PKG_HOME)/bin:$(PKG_HOME)/sbin:$(PATH)" make -f Makefile.goose bmake_inner

bmake_inner: $(PACKAGES)/.gitignore
	rm -rf $(WRKOBJDIR)/bootstrap $(PACKAGES)/bootstrap.tgz
	cd bootstrap && $(PKG_OPT) ./bootstrap --prefix=$(PKG_HOME) --unprivileged --abi 64 --mk-fragment=$(PKG_HOME)/etc/mk.conf --workdir $(WRKOBJDIR)/bootstrap --gzip-binary-kit $(PACKAGES)/bootstrap.tgz --prefer-pkgsrc=yes --ignore-user-check -j4 --compiler=$(CC)

default:
	env CC=$(CC) PATH="$(PKG_HOME)/bin:$(PKG_HOME)/sbin:$(PATH)" make -f Makefile.goose packages

packages: $(WRKOBJDIR)/.gitignore $(PACKAGES)/.gitignore
	cd www/squid3 && $(BMAKE) package
	cd security/openssh && $(BMAKE) package
	-cd wip/runit && $(BMAKE) package
	libexec/fixup-osx-runit
	cd wip/runit && $(BMAKE) package
	cd sysutils/coreutils && $(BMAKE) package
	cd misc/getopt && $(BMAKE) package
	cd misc/figlet && $(BMAKE) package
	cd archivers/bsdtar && $(BMAKE) package
	cd archivers/unzip && $(BMAKE) package
	cd sysutils/daemontools && $(BMAKE) package
	cd chat/irssi && $(BMAKE) package
	cd textproc/libyaml && $(BMAKE) package
	cd textproc/libxml2 && $(BMAKE) package
	cd lang/python27 && $(BMAKE) package

$(PKG_HOME)/bin/bmake:
	tar xvfz $(PACKAGES)/bootstrap.tgz -C /

pkgsrc: $(PKG_HOME)/bin/bmake
	$(PKGADD) getopt figlet coreutils runit irssi unzip bsdtar
	$(PKGADD) libxml2 libyaml
	$(PKGADD) python27

cache: pkgsrc
	$(PKGADD) squid openssh
