#!/usr/bin/env bats

# The bats version of 'source'
load test-template.bats

@test "change the message of the penultimate commit" {
	git checkout -b develop
	penultimate_message="penultimate message"
	last_message="last message"
	git commit -m "${penultimate_message}" --allow-empty
	git commit -m "${last_message}" --allow-empty
	git push -u origin develop
	old_penultimate_matches=$([[ "$(git show HEAD^ --pretty=format:"%B" --no-patch)" == "${penultimate_message}" ]] && echo 1 || echo 0)
	assert [ ${old_penultimate_matches} -eq 1 ]
	new_message="New message"
	git changemessage HEAD^ "${new_message}"
	new_penultimate_matches=$([[ "$(git show HEAD^ --pretty=format:"%B" --no-patch)" == "${new_message}" ]] && echo 1 || echo 0)
	assert [ ${new_penultimate_matches} -eq 1 ]
	last_not_changed=$([[ "$(git show HEAD --pretty=format:"%B" --no-patch)" == "${last_message}" ]] && echo 1 || echo 0)
	assert [ ${last_not_changed} -eq 1 ]
	assert [ -z "$(git diff origin/develop)" ]
}

@test "change the message of the last commit (not abbreviated)" {
	git checkout -b develop
	last_message="last message"
	git commit -m "${last_message}" --allow-empty
	git push -u origin develop
	old_last_matches=$([[ "$(git show HEAD --pretty=format:"%B" --no-patch)" == "${last_message}" ]] && echo 1 || echo 0)
	assert [ ${old_last_matches} -eq 1 ]
	new_message="New message"
	git changemessage "$(git rev-parse HEAD)" "${new_message}"
	new_last_matches=$([[ "$(git show HEAD --pretty=format:"%B" --no-patch)" == "${new_message}" ]] && echo 1 || echo 0)
	assert [ ${new_last_matches} -eq 1 ]
	assert [ -z "$(git diff origin/develop)" ]
}
