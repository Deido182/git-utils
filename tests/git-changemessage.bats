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
	git changemessage -m "${new_message}" HEAD^
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
	git changemessage -m "${new_message}" "$(git rev-parse HEAD)"
	new_last_matches=$([[ "$(git show HEAD --pretty=format:"%B" --no-patch)" == "${new_message}" ]] && echo 1 || echo 0)
	assert [ ${new_last_matches} -eq 1 ]
	assert [ -z "$(git diff origin/develop)" ]
}

@test "replace part of the last 2 commits' messages" {
	git checkout -b develop
	penultimate_message="penultimate message"
	last_message="last message"
	git commit -m "${penultimate_message}" --allow-empty
	git commit -m "${last_message}" --allow-empty
	git push -u origin develop
	old_penultimate_matches=$([[ "$(git show HEAD^ --pretty=format:"%B" --no-patch)" == "${penultimate_message}" ]] && echo 1 || echo 0)
	assert [ ${old_penultimate_matches} -eq 1 ]
	replace="message"
	with="replaced"
	git changemessage -r "${replace}" -w "${with}" develop^..develop
	new_penultimate_matches=$([[ "$(git show HEAD^ --pretty=format:"%B" --no-patch)" == "penultimate replaced" ]] && echo 1 || echo 0)
	assert [ ${new_penultimate_matches} -eq 1 ]
	new_last_matches=$([[ "$(git show HEAD --pretty=format:"%B" --no-patch)" == "last replaced" ]] && echo 1 || echo 0)
	assert [ ${new_last_matches} -eq 1 ]
	assert [ -z "$(git diff origin/develop)" ]
}

@test "fail changing the message of the last commit due to both -m and -r options set" {
	git checkout -b develop
	last_message="last message"
	git commit -m "${last_message}" --allow-empty
	git push -u origin develop
	last_matches=$([[ "$(git show HEAD --pretty=format:"%B" --no-patch)" == "${last_message}" ]] && echo 1 || echo 0)
	assert [ ${last_matches} -eq 1 ]
	new_message="New message"
	run git changemessage -m "${new_message}" -r "message" -w "replaced" "$(git rev-parse HEAD)"
	assert_failure
	last_still_matches=$([[ "$(git show HEAD --pretty=format:"%B" --no-patch)" == "${last_message}" ]] && echo 1 || echo 0)
	assert [ ${last_still_matches} -eq 1 ]
}

@test "add a prefix to the last 2 commits' messages" {
	git checkout -b develop
	penultimate_message="penultimate message"
	last_message="last message"
	git commit -m "${penultimate_message}" --allow-empty
	git commit -m "${last_message}" --allow-empty
	git push -u origin develop
	old_penultimate_matches=$([[ "$(git show HEAD^ --pretty=format:"%B" --no-patch)" == "${penultimate_message}" ]] && echo 1 || echo 0)
	assert [ ${old_penultimate_matches} -eq 1 ]
	prefix="prefix "
	git changemessage -p "${prefix}" develop^ develop
	new_penultimate_matches=$([[ "$(git show HEAD^ --pretty=format:"%B" --no-patch)" == "${prefix}${penultimate_message}" ]] && echo 1 || echo 0)
	assert [ ${new_penultimate_matches} -eq 1 ]
	new_last_matches=$([[ "$(git show HEAD --pretty=format:"%B" --no-patch)" == "${prefix}${last_message}" ]] && echo 1 || echo 0)
	assert [ ${new_last_matches} -eq 1 ]
	assert [ -z "$(git diff origin/develop)" ]
}

@test "fail adding a prefix to the message of the last commit due to both -m and -p options set" {
	git checkout -b develop
	last_message="last message"
	git commit -m "${last_message}" --allow-empty
	git push -u origin develop
	last_matches=$([[ "$(git show HEAD --pretty=format:"%B" --no-patch)" == "${last_message}" ]] && echo 1 || echo 0)
	assert [ ${last_matches} -eq 1 ]
	new_message="New message"
	run git changemessage -m "${new_message}" -p "prefix " HEAD
	assert_failure
	last_still_matches=$([[ "$(git show HEAD --pretty=format:"%B" --no-patch)" == "${last_message}" ]] && echo 1 || echo 0)
	assert [ ${last_still_matches} -eq 1 ]
}

@test "change the message of some commits" {
	git checkout -b develop
	git commit -m "commit 1" --allow-empty
	git commit -m "commit 2" --allow-empty
	git commit -m "commit 3" --allow-empty
	git commit -m "commit 4" --allow-empty
	git commit -m "commit 5" --allow-empty
	git commit -m "commit 6" --allow-empty
	git commit -m "commit 7" --allow-empty
	git push -u origin develop
	new_message="New message"
	git changemessage -m "${new_message}" HEAD^^^^..HEAD^^ HEAD HEAD^^^^^^ HEAD^^..HEAD^^
	mods_ok=$([[ "$(git log --pretty=%s | grep -o "${new_message}" | wc -l)" == 5 ]] && echo 1 || echo 0)
	assert [ ${mods_ok} -eq 1 ]
	commit_2_not_changed=$([[ "$(git show HEAD^^^^^ --pretty=format:"%B" --no-patch)" == "commit 2" ]] && echo 1 || echo 0)
	assert [ ${commit_2_not_changed} -eq 1 ]
	commit_6_not_changed=$([[ "$(git show HEAD^ --pretty=format:"%B" --no-patch)" == "commit 6" ]] && echo 1 || echo 0)
	assert [ ${commit_6_not_changed} -eq 1 ]
	assert [ -z "$(git diff origin/develop)" ]
}

@test "append a prefix to some commits" {
	git checkout -b develop
	git commit -m "commit 1" --allow-empty
	git commit -m "commit 2" --allow-empty
	git commit -m "commit 3" --allow-empty
	git commit -m "commit 4" --allow-empty
	git commit -m "commit 5" --allow-empty
	git commit -m "commit 6" --allow-empty
	git commit -m "commit 7" --allow-empty
	git push -u origin develop
	prefix="New prefix "
	git changemessage -p "${prefix}" HEAD^^^^..HEAD^^ HEAD HEAD^^^^^^ HEAD^^..HEAD^^
	mods_ok=$([[ "$(git log --pretty=%s | grep -o "${prefix}" | wc -l)" == 5 ]] && echo 1 || echo 0)
	assert [ ${mods_ok} -eq 1 ]
	commit_2_not_changed=$([[ "$(git show HEAD^^^^^ --pretty=format:"%B" --no-patch)" == "commit 2" ]] && echo 1 || echo 0)
	assert [ ${commit_2_not_changed} -eq 1 ]
	commit_6_not_changed=$([[ "$(git show HEAD^ --pretty=format:"%B" --no-patch)" == "commit 6" ]] && echo 1 || echo 0)
	assert [ ${commit_6_not_changed} -eq 1 ]
	assert [ -z "$(git diff origin/develop)" ]
}

@test "fail due to invalid range" {
	git checkout -b develop
	git commit -m "commit 1" --allow-empty
	git commit -m "commit 2" --allow-empty
	git commit -m "commit 3" --allow-empty
	git commit -m "commit 4" --allow-empty
	git commit -m "commit 5" --allow-empty
	git commit -m "commit 6" --allow-empty
	git commit -m "commit 7" --allow-empty
	git push -u origin develop
	new_message="New message"
	run git changemessage -m "${new_message}" HEAD^^^^..HEAD^^ HEAD HEAD^^^^^^ HEAD^..HEAD^^
	assert_failure
	assert [ -z "$(git diff origin/develop)" ]
}
