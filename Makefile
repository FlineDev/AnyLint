SHELL = /bin/bash

prefix ?= /usr/local
bindir ?= $(prefix)/bin
libdir ?= $(prefix)/lib
srcdir = Sources

REPODIR = $(shell pwd)
BUILDDIR = $(REPODIR)/.build
SOURCES = $(wildcard $(srcdir)/**/*.swift)

.DEFAULT_GOAL = all

.PHONY: all
all: anylint

anylint: $(SOURCES)
	@swift build \
		-c release \
		--disable-sandbox \
		--build-path "$(BUILDDIR)"

.PHONY: install
install: anylint
	@install -d "$(bindir)" "$(libdir)"
	@install "$(BUILDDIR)/release/anylint" "$(bindir)"

.PHONY: uninstall
uninstall:
	@rm -rf "$(bindir)/anylint"

.PHONY: clean
distclean:
	@rm -f $(BUILDDIR)/release

.PHONY: clean
clean: distclean
	@rm -rf $(BUILDDIR)
