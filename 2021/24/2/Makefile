solve: ../input
	@perl aoc.pl < $<

test:
	@true

../input: ../../../.cookie
	@curl -H"$$(cat $<)" -o $@ https://adventofcode.com/2021/day/24/input
