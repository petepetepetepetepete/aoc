%:
	@for x in */day/*/part* ; do \
		$(MAKE) -C $$x $@ ; \
	done
