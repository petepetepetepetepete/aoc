solve: ../input
	@perl aoc.pl 64 < $<

test:
	@prove -mvw t/examples.t

../input: ../../../.cookie
	curl -H"$$(cat $<)" -o $@ https://adventofcode.com/2023/day/21/input
