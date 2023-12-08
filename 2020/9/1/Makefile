solve: ../input
	@perl aoc.pl 25 < $<

test:
	@prove -mvw t/examples.t

../input: ../../../.cookie
	@curl -H"$$(cat $<)" -o $@ https://adventofcode.com/2020/day/9/input
