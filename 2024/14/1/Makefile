solve: ../input
	@perl aoc.pl < $<

test:
	@COLUMNS=11 ROWS=7 prove -mvw t/examples.t

../input: ../../../.cookie
	curl -H"$$(cat $<)" -o $@ https://adventofcode.com/2024/day/14/input
