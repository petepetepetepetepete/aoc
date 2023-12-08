solve: ../input
	@perl aoc.pl < $<

test:
	@true

../input: ../../../.cookie
	@curl -H"$$(cat $<)" -o $@ https://adventofcode.com/2020/day/5/input
