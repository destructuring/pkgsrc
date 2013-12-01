# depends on:
#   externally defined PKG_HOME, CC, PATH
#   vault symlink in $(PWD) to distfiles, packages
#   suggestion:
#     env CC=clang PKG_HOME=$HOME/pkg PATH="$HOME/pkg/bin:$HOME/pkg/sbin:$PATH" make -f Makefile.goose
PKG_ID := $(shell uname -s)$(shell echo $(PKG_HOME) | tr / _)

PKGPATH := $(PWD)/packages/$(PKG_ID)
WRKOBJDIR := $(PWD)/work

PKGSRC := env MAKEFLAGS= MFLAGS= PACKAGES=$(PKGPATH) WRKOBJDIR=$(WRKOBJDIR)
BMAKE = $(PKGSRC) $(PKG_HOME)/bin/bmake

$(WRKOBJDIR)/.gitignore:
	mkdir -p $(WRKOBJDIR)
	touch $@

$(PKGPATH)/.gitignore:
	mkdir -p $(PKGPATH)
	touch $@

bmake: $(PKGPATH)/.gitignore
	rm -rf $(WRKOBJDIR)/bootstrap $(PKGPATH)/bootstrap.tgz
	cd bootstrap && $(PKGSRC) ./bootstrap --prefix=$(PKG_HOME) --unprivileged --abi 64 --mk-fragment=$(PKG_HOME)/etc/mk.conf --workdir $(WRKOBJDIR)/bootstrap --gzip-binary-kit $(PKGPATH)/bootstrap.tgz --prefer-pkgsrc=yes --ignore-user-check -j4 --compiler=$(CC)

$(PKG_HOME)/bin/bmake: bmake

packages: $(PKG_HOME)/bin/bmake $(WRKOBJDIR)/.gitignore  $(PKGPATH)/.gitignore
	cd www/squid3 && $(BMAKE) package
	cd sysutils/coreutils && $(BMAKE) package
	cd misc/figlet && $(BMAKE) package
