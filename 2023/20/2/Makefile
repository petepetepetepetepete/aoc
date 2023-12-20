solve: ../input
	@perl aoc.pl < $<

test:
	@true

../input: ../../../.cookie
	curl -H"$$(cat $<)" -o $@ https://adventofcode.com/2023/day/20/input
