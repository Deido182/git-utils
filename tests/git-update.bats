#!/usr/bin/env bats

# The bats version of 'source'
load test-template.bats

@test "update remote custom" {
	git branch custom
	git push -u origin custom
	git commit -m "commit to push" --allow-empty
	git update custom
	same_head=$([[ $(git rev-parse custom) == $(git rev-parse origin/custom) ]] && echo 1 || echo 0)
    assert [ ${same_head} -eq 1 ]
}

@test "update remote custom even with other commits in between" {
	git branch custom
	git push -u origin custom
	# feature/1 updates custom
	git checkout -b feature/1
	echo "file1" > file1
	git add --all
	git commit -m "commit on feature/1 adding file1"
	git update custom
	# Back to master
	git checkout master
	# feature/2 updates custom
	git checkout -b feature/2
	echo "file2" > file2
	git add --all
	git commit -m "commit on feature/2 adding file2"
	git update custom
	# feature/1 updates custom again
	git checkout feature/1
	echo "new content file1" > file1
	git add --all
	git commit -m "commit on feature/1 modifies file1"
	git update custom
	back_on_feature_1=$([[ $(git rev-parse --abbrev-ref HEAD) == feature/1 ]] && echo 1 || echo 0)
	assert [ ${back_on_feature_1} -eq 1 ]
	od_contains_f=$([[ ! -z "$(git branch -r --contains feature/1 | grep '^\s*origin/custom$')" ]] && echo 1 || echo 0)
    assert [ ${od_contains_f} -eq 1 ]
	same_head_d_od=$([[ $(git rev-parse custom) == $(git rev-parse origin/custom) ]] && echo 1 || echo 0)
    assert [ ${same_head_d_od} -eq 1 ]
}

@test "fail updating remote custom due to merge conflicts" {
	git branch custom
	git push -u origin custom
	git checkout -b other
	echo "first content" > file
	git add --all
	git commit -m "commit on other adding file"
	git update custom
	# First time ok
	same_head=$([[ $(git rev-parse other) == $(git rev-parse origin/custom) ]] && echo 1 || echo 0)
    assert [ ${same_head} -eq 1 ]
    back_on_other=$([[ $(git rev-parse --abbrev-ref HEAD) == other ]] && echo 1 || echo 0)
    assert [ ${back_on_other} -eq 1 ]
    git checkout custom
    echo "second content" > file
    git add --all
    git commit -m "commit on custom altering file"
    git push
    git checkout other
    echo "third content" > file
    git add --all
    git commit -m "commit on other altering file again"
    git update custom
    # Second time fails
    diff_head=$([[ $(git rev-parse other) != $(git rev-parse origin/custom) ]] && echo 1 || echo 0)
    assert [ ${diff_head} -eq 1 ]
    still_on_custom=$([[ $(git rev-parse --abbrev-ref HEAD) == custom ]] && echo 1 || echo 0)
    assert [ ${still_on_custom} -eq 1 ]
}
