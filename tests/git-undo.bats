#!/usr/bin/env bats

# The bats version of 'source'
load test-template.bats

@test "undo last 2 commits" {
	head_before=$(git rev-parse HEAD)
	git commit --allow-empty
	git commit --allow-empty
	head_after=$(git rev-parse HEAD)
	assert [[ ${head_before} != ${head_after} ]]
	git undo 2
	head_final=$(git rev-parse HEAD)
	assert [[ ${head_before} == ${head_final} ]]
}
