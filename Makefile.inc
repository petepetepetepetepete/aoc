ifeq ($(SUBDIRS),)
	$(error "Must provide SUBDIRS before including")
endif

.PHONY: $(SUBDIRS)

SUBDIRS_SOLVE := $(foreach d, $(SUBDIRS), $(d).solve)
SUBDIRS_TEST := $(foreach d, $(SUBDIRS), $(d).test)

all: test solve
solve: $(SUBDIRS_SOLVE)
test: $(SUBDIRS_TEST)

%.solve:
	$(MAKE) -C $* solve

%.test:
	$(MAKE) -C $* test
