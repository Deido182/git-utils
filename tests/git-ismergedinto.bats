#!/usr/bin/env bats

# The bats version of 'source'
load test-template.bats

@test "assert that current branch is merged into origin/develop" {
	git branch develop
	git push -u origin develop
	git checkout -b feature
	is_merged=$([[ $(git ismergedinto develop) == true ]] && echo 1 || echo 0)
    assert [ ${is_merged} -eq 1 ]
    echo test > file
    git add --all
	git commit -m "commit"
	is_merged=$([[ $(git ismergedinto develop) == true ]] && echo 1 || echo 0)
    assert [ ${is_merged} -eq 0 ]
    git checkout develop
    git merge feature
    is_merged=$([[ $(git ismergedinto develop) == true ]] && echo 1 || echo 0)
    assert [ ${is_merged} -eq 1 ]
    is_merged=$([[ $(git ismergedinto origin/develop) == true ]] && echo 1 || echo 0)
    assert [ ${is_merged} -eq 0 ]
    git push
    is_merged=$([[ $(git ismergedinto origin/develop) == true ]] && echo 1 || echo 0)
    assert [ ${is_merged} -eq 1 ]
}

@test "assert that feature branch is merged into develop" {
	git branch develop
	git checkout -b feature
    echo test > file
    git add --all
	git commit -m "commit"
	git checkout -b other
	is_merged=$([[ $(git ismergedinto -b feature develop) == true ]] && echo 1 || echo 0)
    assert [ ${is_merged} -eq 0 ]
    git checkout develop
    git merge feature
    git checkout other
    is_merged=$([[ $(git ismergedinto -b feature develop) == true ]] && echo 1 || echo 0)
    assert [ ${is_merged} -eq 1 ]
    is_merged=$([[ $(git ismergedinto -b feature origin/develop) == true ]] && echo 1 || echo 0)
    assert [ ${is_merged} -eq 0 ]
    git push -u origin develop
    is_merged=$([[ $(git ismergedinto -b feature origin/develop) == true ]] && echo 1 || echo 0)
    assert [ ${is_merged} -eq 1 ]
}

@test "list all branches feature is merged into" {
	git branch develop
	git branch other
	git checkout -b feature
    echo test > file
    git add --all
	git commit -m "commit"
	git checkout other
	just_one=$([[ "$(git ismergedinto -lb feature)" == "feature" ]] && echo 1 || echo 0)
    assert [ ${just_one} -eq 1 ]
    git checkout develop
    git merge feature
    git push -u origin develop
    git checkout master
    git merge feature
    git checkout feature
    three=$([[ $(echo "$(git ismergedinto -l)" | wc -l) == 4 ]] && echo 1 || echo 0)
    assert [ ${three} -eq 1 ]
}

@test "fail listing all branches feature is merged into" {
	git branch develop
	git checkout -b feature
    echo test > file
    git add --all
	git commit -m "commit"
	git checkout develop
    git merge feature
	run git ismergedinto -l develop
	assert_failure
}

@test "fail for missing parameter" {
	git branch develop
	git checkout -b feature
    echo test > file
    git add --all
	git commit -m "commit"
	git checkout develop
    git merge feature
	run git ismergedinto
	assert_failure
}
