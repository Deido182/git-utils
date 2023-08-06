#!/usr/bin/env bats

# The bats version of 'source'
load test-template.bats

@test "update remote develop" {
	git push -u origin develop
	git commit -m "commit to push" --allow-empty
	git updatedev
	same_head=$([[ $(git rev-parse develop) == $(git rev-parse origin/develop) ]] && echo 1 || echo 0)
    assert [ ${same_head} -eq 1 ]
}
