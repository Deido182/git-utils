#!/usr/bin/env bats

# The bats version of 'source'
load test-template.bats

@test "undo last 2 commits" {
	head_before=$(git rev-parse HEAD)
	echo ${head_before}
	echo test > test_file
	git add --all
	git commit -m "message 1"
	git commit -m "message 2" --allow-empty 
	head_after=$(git rev-parse HEAD)
	assert [[ ${head_before} != ${head_after} ]]
	git undo 2
	head_final=$(git rev-parse HEAD)
	assert [[ ${head_before} == ${head_final} ]]
	assert [[ -f "test_file" ]]
}
