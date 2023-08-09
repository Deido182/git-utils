#!/usr/bin/env bats

# The bats version of 'source'
load test-template.bats

@test "change the message of the penultimate commit" {
		penultimate_message="penultimate message"
		git commit -m "${penultimate_message}" --allow-empty 
		git commit -m "last message" --allow-empty
		old_matches=$([[ "$(git show HEAD^ --pretty=format:"%B" --no-patch)" == "${penultimate_message}" ]] && echo 1 || echo 0)
		assert [ ${old_matches} -eq 1 ]
		new_message="New message"
		git changemessage HEAD^ "${new_message}"
		new_matches=$([[ "$(git show HEAD^ --pretty=format:"%B" --no-patch)" == "${new_message}" ]] && echo 1 || echo 0)
		assert [ ${new_matches} -eq 1 ]
}
