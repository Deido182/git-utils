#!/usr/bin/env bats

# The bats version of 'source'
load test-template.bats

other_branch=other

@test "move last 2 commits to a new branch" {
        head_initial=$(git rev-parse HEAD)
        git commit -m "first commit to move" --allow-empty
        git commit -m "second commit to move" --allow-empty
        last_commit_head=$(git rev-parse HEAD)
        git movelaststo ${other_branch} 2
        head_final=$(git rev-parse HEAD)
        same_head=$([[ ${head_initial} == ${head_final} ]] && echo 1 || echo 0)
        assert [ ${same_head} -eq 1 ]
        branch_exists=$([[ ! -z "$(git branch --list ${other_branch})" ]] && echo 1 || echo 0)
        assert [ ${branch_exists} -eq 1 ]
        last_commit_ok=$([[ $(git rev-parse ${other_branch}) == ${last_commit_head} ]] && echo 1 || echo 0)
        assert [ ${last_commit_ok} -eq 1 ]
}

@test "move last 2 commits to an existing branch" {
		curr_branch=$(git rev-parse --abbrev-ref HEAD)
        head_initial=$(git rev-parse HEAD)
		git checkout -b ${other_branch}
		git commit -m "commit other branch" --allow-empty
		git checkout ${curr_branch}
        branch_exists=$([[ ! -z "$(git branch --list ${other_branch})" ]] && echo 1 || echo 0)
        assert [ ${branch_exists} -eq 1 ]
        git commit -m "first commit to move" --allow-empty
        first_commit=$(git rev-parse HEAD)
        git commit -m "second commit to move" --allow-empty
        second_commit=$(git rev-parse HEAD)
        git movelaststo ${other_branch} 2
        head_final=$(git rev-parse HEAD)
        same_head=$([[ ${head_initial} == ${head_final} ]] && echo 1 || echo 0)
        assert [ ${same_head} -eq 1 ]
        # In this case it is not guaranteed that '$(git rev-parse HEAD) == ${second_commit}'
        contains_first=$(git branch --contains ${first_commit} | grep "${other_branch}" | wc -l)
        contains_second=$(git branch --contains ${second_commit} | grep "${other_branch}" | wc -l)
        contains_both=$([[ ${contains_first} == 1 ]] && [[ ${contains_second} == 1 ]] && echo 1 || echo 0)
        assert [ ${contains_both} -eq 1 ]
}
