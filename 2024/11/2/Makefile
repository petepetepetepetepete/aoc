solve: ../input
	@perl aoc.pl < $<

test:
	@true

../input: ../../../.cookie
	curl -H"$$(cat $<)" -o $@ https://adventofcode.com/2024/day/11/input
