#!/usr/bin/env bats

# The bats version of 'source'
load test-template.bats

@test "save some mods and then restore them" {
	git branch develop
	echo "proper content 1" > file1
	echo "proper content 2" > file2
	git add --all
	git commit -m "proper changes"
	last_proper_commit=$(git rev-parse HEAD)
	new_content_file1="new content for local run"
	echo ${new_content_file1} > file1
	git add file1
	rm file2
	git localsetup save dev
	no_diff=$([[ -z "$(git diff ${last_proper_commit})" ]] && echo 1 || echo 0)
    assert [ ${no_diff} -eq 1 ]
    git localsetup use dev
    modified_file_1=$([[ "$(cat file1)" == ${new_content_file1} ]] && echo 1 || echo 0)
    no_file_2=$([[ ! -f file2 ]] && echo 1 || echo 0)
    assert [ ${no_file_2} -eq 1 ]
}
