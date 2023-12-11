solve: ../input
	@perl aoc.pl 1000000 < $<

test:
	@prove -mvw t/examples.t

../input: ../../../.cookie
	curl -H"$$(cat $<)" -o $@ https://adventofcode.com/2023/day/11/input
