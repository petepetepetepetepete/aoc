solve: ../input
	@perl aoc.pl < $<

test:
	@TEST=1 prove -mvw t/examples.t

../input: ../../../.cookie
	curl -H"$$(cat $<)" -o $@ https://adventofcode.com/2023/day/24/input
