#!/usr/bin/env bats

# The bats version of 'source'
load test-template.bats

@test "successfully detect last commits changing a range of lines" {
	echo "a" > file
	echo "b" >> file
	echo "c" >> file
	git add --all
	git commit -m "First"
	sleep 1
	echo "a" > file
	echo "b" >> file
	echo "d" >> file
	echo "e" >> file
	git add --all
	git commit -m "Third line modified"
	sleep 1
	echo "a" > file
	echo "b" >> file
	echo "d" >> file
	echo "f" >> file
	git add --all
	git commit -m "Fourth line modified"
	expected="$(git rev-parse HEAD^) $(git rev-parse HEAD^^) "
	actual="$(git showaffecting file 2 3 | grep "^commit" | cut -d ' ' -f 2 | tr '\n' ' ')"
	assert_equal "${actual}" "${expected}"
	git checkout HEAD^^
	expected="$(git rev-parse HEAD) "
	actual="$(git showaffecting file 2 2 | grep "^commit" | cut -d ' ' -f 2 | tr '\n' ' ')"
	assert_equal "${actual}" "${expected}"
}
