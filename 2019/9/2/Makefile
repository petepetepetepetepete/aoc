solve: ../input
	@echo 2 | perl ../1/aoc.pl $<

test:
	@true

../input: ../../../.cookie
	@curl -H"$$(cat $<)" -o $@ https://adventofcode.com/2019/day/9/input
