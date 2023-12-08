visualization: ../input
	@perl aoc.pl $< 1

../input: ../../../.cookie
	@curl -H"$$(cat $<)" -o $@ https://adventofcode.com/2019/day/13/input
