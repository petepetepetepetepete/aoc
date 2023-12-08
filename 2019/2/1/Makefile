solve: ../input
	@perl aoc.pl 12 2 0 < $<

test:
	@prove -mvw t/examples.t

../input: ../../../.cookie
	@curl -H"$$(cat $<)" -o $@ https://adventofcode.com/2019/day/2/input
