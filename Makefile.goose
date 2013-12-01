# depends on:
#   externally defined PKG_HOME, CC, PATH
#   vault symlink in $(PWD) to distfiles, packages
#   suggestion:
#     env CC=clang PKG_HOME=$HOME/pkg PATH="$HOME/pkg/bin:$HOME/pkg/sbin:$PATH" make -f Makefile.goose
PKG_ID := $(shell uname -s)$(shell echo $(PKG_HOME) | tr / _)

PKGPATH := $(PWD)/packages/$(PKG_ID)
WRKDIR := $(PWD)/work

PKGSRC := env MAKEFLAGS= MFLAGS= PACKAGES=$(PKGPATH)
BMAKE = $(PKGSRC) WRKDIR=$(WRKDIR) $(PKG_HOME)/bin/bmake
PKGADD := env PKG_PATH=$(PKGPATH)/All $(PKG_HOME)/sbin/pkg_add

$(WRKDIR)/.gitignore:
	mkdir -p $(WRKDIR)
	touch $@

$(PKGPATH)/.gitignore:
	mkdir -p $(PKGPATH)
	touch $@

build_bmake: $(PKGPATH)/.gitignore
	rm -rf $(WRKDIR)/bootstrap $(PKGPATH)/bootstrap.tgz
	cd bootstrap && $(PKGSRC) ./bootstrap --prefix=$(PKG_HOME) --unprivileged --abi 64 --mk-fragment=$(PKG_HOME)/etc/mk.conf --workdir $(WRKDIR)/bootstrap --gzip-binary-kit $(PKGPATH)/bootstrap.tgz --prefer-pkgsrc=yes --ignore-user-check -j4 --compiler=$(CC)

$(PKG_HOME)/bin/bmake: build_bmake

build_pkgsrc: $(PKG_HOME)/bin/bmake $(WRKDIR)/.gitignore  $(PKGPATH)/.gitignore
	cd www/squid3 && $(BMAKE) install package
	cd sysutils/coreutils && $(BMAKE) install package
	cd misc/figlet && $(BMAKE) install package

pkgsrc:
	$(PKGADD) libiconv gettext-lib zlib getopt unzip coreutils figlet curl wget
	$(PKGADD) libxml2 libxslt gnupg 

pkgsrc_x11: pkgsrc
	$(PKGADD) xtermset

pkgsrc_cache: pkgsrc
	$(PKGADD) squid
	$(PKGADD) openssh

pkgsrc_ruby: $(PKG_HOME)bin/bundle

pkgsrc_lua:
	$(PKGADD) pcre
	$(PKGADD) lua

$(PKG_HOME)/bin/bundle: $(PKG_HOME)/bin/ruby $(PKG_HOME)/bin/gem $(PKG_HOME)/bin/irb
	gem install bundler -v '~> 1.3.5'

$(PKG_HOME)/bin/ruby193: pkgsrc
	$(PKGADD) ruby193-base ruby193-readline

$(PKG_HOME)/bin/gem193: $(PKG_HOME)/bin/ruby193

$(PKG_HOME)/bin/ruby: $(PKG_HOME)/bin/ruby193
	ln -nfs $(shell basename $<) $@

$(PKG_HOME)/bin/gem: $(PKG_HOME)/bin/gem193
	ln -nfs $(shell basename $<) $@

$(PKG_HOME)/bin/irb: $(PKG_HOME)/bin/irb193
	ln -nfs $(shell basename $<) $@
