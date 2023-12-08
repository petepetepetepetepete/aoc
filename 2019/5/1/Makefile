solve: ../input
	@echo 1 | perl aoc.pl $< | tail -n1

test:
	@true

../input: ../../../.cookie
	@curl -H"$$(cat $<)" -o $@ https://adventofcode.com/2019/day/5/input
