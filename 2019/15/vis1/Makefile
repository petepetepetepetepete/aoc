visualization: ../input
	@perl aoc.pl $<

../input: ../../../.cookie
	@curl -H"$$(cat $<)" -o $@ https://adventofcode.com/2019/day/15/input
