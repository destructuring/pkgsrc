# depends on:
#   externally defined PKG_HOME, CC, PATH
#   vault symlink in $(PWD) to distfiles, packages
#   suggestion:
#     env CC=clang PKG_HOME=/opt/goose/pkg PATH="/opt/goose/pkg/bin:/opt/goose/pkg/sbin:$PATH" make -f Makefile.goose

.PHONY: $(PKG) packages
PKG_ID := $(shell uname -s)$(shell echo $(PKG_HOME) | tr / _)

PKGPATH := $(PWD)/packages/$(PKG_ID)
WRKOBJDIR := $(PWD)/work

PKGSRC := env MAKEFLAGS= MFLAGS= PACKAGES=$(PKGPATH) WRKOBJDIR=$(WRKOBJDIR)
BMAKE = $(PKGSRC) $(PKG_HOME)/bin/bmake

PARENT := $(shell cd .. && pwd)

SH := /bin/bash

CC := $(shell basename $(shell which clang gcc | head -1))

default:
	@echo env CC=$(CC) PKG_HOME=$(PARENT)/pkg PATH="$(PARENT)/pkg/bin:$(PARENT)/pkg/sbin:\$$PATH" make -f Makefile.goose
	@echo make bmake
	@echo make packages

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

packages: $(WRKOBJDIR)/.gitignore  $(PKGPATH)/.gitignore
	cd www/squid3 && $(BMAKE) package
	cd sysutils/coreutils && $(BMAKE) package
	cd misc/getopt && $(BMAKE) package
	cd misc/figlet && $(BMAKE) package
	cd archivers/bsdtar && $(BMAKE) package
	cd archivers/unzip && $(BMAKE) package
	cd sysutils/daemontools && $(BMAKE) package
	-cd wip/runit && $(BMAKE) package
	libexec/fixup-osx-runit
	cd wip/runit && $(BMAKE) package
	cd security/openssh && $(BMAKE) package
	cd chat/irssi && $(BMAKE) package

ruby:
	cd textproc/libxml2 && $(BMAKE) package
	-cd lang/ruby193-base && $(BMAKE) package
	libexec/fixup-ubuntu-ruby
	cd lang/ruby193-base && $(BMAKE) package
	cd devel/ruby-readline && $(BMAKE) package

$(PKG):
	cd $(PKG) && $(BMAKE) package

pkg: $(PKG)
