solve: ../input
	@perl aoc.pl < $<

test:
	@prove -mvw t/examples.t

../input: ../../../.cookie
	@curl -H"$$(cat $<)" -o $@ https://adventofcode.com/2019/day/10/input
