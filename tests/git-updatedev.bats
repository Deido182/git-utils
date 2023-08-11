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

@test "update remote develop even with other commits in between" {
	git branch develop
	git push -u origin develop
	# feature/1 updates develop
	git checkout -b feature/1
	echo "file1" > file1
	git add --all
	git commit -m "commit on feature/1 adding file1"
	git updatedev
	# Back to master
	git checkout master
	# feature/2 updates develop
	git checkout -b feature/2
	echo "file2" > file2
	git add --all
	git commit -m "commit on feature/2 adding file2"
	git updatedev
	# feature/1 updates develop again
	git checkout feature/1
	echo "new content file1" > file1
	git add --all
	git commit -m "commit on feature/1 modifies file1"
	git updatedev
	back_on_feature_1=$([[ $(git rev-parse --abbrev-ref HEAD) == feature/1 ]] && echo 1 || echo 0)
	assert [ ${back_on_feature_1} -eq 1 ]
	od_contains_f=$([[ ! -z "$(git branch -r --contains feature/1 | grep '^\s*origin/develop$')" ]] && echo 1 || echo 0)
    assert [ ${od_contains_f} -eq 1 ]
	same_head_d_od=$([[ $(git rev-parse develop) == $(git rev-parse origin/develop) ]] && echo 1 || echo 0)
    assert [ ${same_head_d_od} -eq 1 ]
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
