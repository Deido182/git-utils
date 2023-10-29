#!/usr/bin/env bats

# The bats version of 'source'
load test-template.bats

@test "undo last 2 commits" {
	head_before=$(git rev-parse HEAD)
	echo test >test_file
	git add --all
	git commit -m "message 1"
	git commit -m "message 2" --allow-empty
	head_after=$(git rev-parse HEAD)
	diff_head=$([[ ${head_before} != ${head_after} ]] && echo 1 || echo 0)
	assert [ ${diff_head} -eq 1 ]
	git undo 2
	head_final=$(git rev-parse HEAD)
	same_head=$([[ ${head_before} == ${head_final} ]] && echo 1 || echo 0)
	file_exists=$([[ -f "test_file" ]] && echo 1 || echo 0)
	assert [ ${same_head} -eq 1 ]
	assert [ ${file_exists} -eq 1 ]
}
