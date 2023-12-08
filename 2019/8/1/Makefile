solve: ../input
	@perl aoc.pl 25 6 < $<

test:
	@true

../input: ../../../.cookie
	@curl -H"$$(cat $<)" -o $@ https://adventofcode.com/2019/day/8/input
