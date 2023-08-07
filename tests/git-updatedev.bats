#!/usr/bin/env bats

# The bats version of 'source'
load test-template.bats

@test "update remote develop" {
	git branch develop
	git push -u origin develop
	git commit -m "commit to push" --allow-empty
	git updatedev
	same_head=$([[ $(git rev-parse develop) == $(git rev-parse origin/develop) ]] && echo 1 || echo 0)
    assert [ ${same_head} -eq 1 ]
}

@test "fail updating remote develop due to merge conflicts" {
	git branch develop
	git push -u origin develop
	git checkout -b other
	echo "first content" > file
	git add --all
	git commit -m "commit on other adding file"
	git updatedev
	# First time ok
	same_head=$([[ $(git rev-parse other) == $(git rev-parse origin/develop) ]] && echo 1 || echo 0)
    assert [ ${same_head} -eq 1 ]
    back_on_other=$([[ $(git rev-parse --abbrev-ref HEAD) == other ]] && echo 1 || echo 0)
    assert [ ${back_on_other} -eq 1 ]
    git checkout develop
    echo "second content" > file
    git add --all
    git commit -m "commit on develop altering file"
    git push
    git checkout other
    echo "third content" > file
    git add --all
    git commit -m "commit on other altering file again"
    git updatedev
    # Second time fails
    diff_head=$([[ $(git rev-parse other) != $(git rev-parse origin/develop) ]] && echo 1 || echo 0)
    assert [ ${diff_head} -eq 1 ]
    still_on_develop=$([[ $(git rev-parse --abbrev-ref HEAD) == develop ]] && echo 1 || echo 0)
    assert [ ${still_on_develop} -eq 1 ]
}
