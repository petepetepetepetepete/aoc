%:
	@for x in 20*/*/[12] ; do \
		$(MAKE) -C $$x $@ ; \
	done
