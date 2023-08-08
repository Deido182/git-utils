#!/usr/bin/env bats

# The bats version of 'source'
load test-template.bats

@test "update remote release/1.0.0 from a feature" {
	release=release/1.0.0
	feature=feature/x
	git branch ${release}
	git push -u origin ${release}
	git checkout -b ${feature}
	git commit -m "commit to push" --allow-empty
	git updatetest 1.0.0
	same_head=$([[ $(git rev-parse ${feature}) == $(git rev-parse origin/${release}) ]] && echo 1 || echo 0)
    assert [ ${same_head} -eq 1 ]
}

@test "fail updating remote release/1.0.0 from a not-feature branch" {
	release=release/1.0.0
	git branch ${release}
	git push -u origin ${release}
	git checkout -b other
	git commit -m "commit to push" --allow-empty
	# To prevent it from stopping the test on failure
	run ! git updatetest 1.0.0
	assert_failure
	diff_head=$([[ $(git rev-parse other) != $(git rev-parse origin/${release}) ]] && echo 1 || echo 0)
    assert [ ${diff_head} -eq 1 ]
    still_on_other=$([[ $(git rev-parse --abbrev-ref HEAD) == other ]] && echo 1 || echo 0)
    assert [ ${still_on_other} -eq 1 ]
}

@test "fail updating remote release/1.0.0 as a greater one exists" {
	release=release/1.0.0
	greater_release=release/1.0.1
	feature=feature/x
	git branch ${release}
	git push -u origin ${release}
	git branch ${greater_release}
	git push -u origin ${greater_release}
	git checkout -b ${feature}
	git commit -m "commit to push" --allow-empty
	# To prevent it from stopping the test on failure
	run ! git updatetest 1.0.0
	assert_failure
	diff_head=$([[ $(git rev-parse ${feature}) != $(git rev-parse origin/${release}) ]] && echo 1 || echo 0)
    assert [ ${diff_head} -eq 1 ]
    still_on_feature=$([[ $(git rev-parse --abbrev-ref HEAD) == ${feature} ]] && echo 1 || echo 0)
    assert [ ${still_on_feature} -eq 1 ]
}
