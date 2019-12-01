%:
	for x in */day/*/part* ; do \
		make -C $$x $@ ; \
	done
