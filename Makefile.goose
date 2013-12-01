# depends on:
#   externally defined PKG_HOME, CC
#   vault symlink in $(PWD) to distfiles, packages
PKG_ID := $(shell uname -s)$(shell echo $(PKG_HOME) | tr / _)
PKGPATH := $(PWD)/packages/$(PKG_ID)
BOOTSTRAPKIT := $(PWD)/packages/$(PKG_ID)/bootstrap.tgz
WRKDIR := $(PWD)/work
PKGSRC := env MAKEFLAGS= MFLAGS= PACKAGES=$(PKGPATH) WRKDIR=$(WRKDIR)
BMAKE = $(PKGSRC) $(PKG_HOME)/bin/bmake
PKGADD := env PKG_PATH=$(PKGPATH)/All $(PKG_HOME)/sbin/pkg_add

build_bmake:
	rm -rf bootstrap/work
	cd bootstrap && $(PKGSRC) ./bootstrap --prefix=$(PKG_HOME) --unprivileged --abi 64 --mk-fragment=$(PKG_HOME)/etc/mk.conf --workdir $(WRKDIR) --gzip-binary-kit $(BOOTSTRAPKIT) --prefer-pkgsrc=yes --ignore-user-check -j4 --compiler=$(CC)

build_pkgsrc: $(PKG_HOME)/bin/bmake
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
