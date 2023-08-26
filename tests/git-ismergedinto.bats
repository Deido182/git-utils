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
