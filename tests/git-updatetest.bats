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

@test "update remote release/1.0.0 even with other commits in between" {
	release=release/1.0.0
	git branch ${release}
	git push -u origin ${release}
	# feature/1 updates release/1.0.0
	git checkout -b feature/1
	echo "file1" >file1
	git add --all
	git commit -m "commit on feature/1 adding file1"
	git updatetest 1.0.0
	# Back to master
	git checkout master
	# feature/2 updates release/1.0.0
	git checkout -b feature/2
	echo "file2" >file2
	git add --all
	git commit -m "commit on feature/2 adding file2"
	git updatetest 1.0.0
	# feature/1 updates release/1.0.0 again
	git checkout feature/1
	echo "new content file1" >file1
	git add --all
	git commit -m "commit on feature/1 modifies file1"
	git updatetest 1.0.0
	back_on_feature_1=$([[ $(git rev-parse --abbrev-ref HEAD) == feature/1 ]] && echo 1 || echo 0)
	assert [ ${back_on_feature_1} -eq 1 ]
	or_contains_f=$([[ ! -z "$(git branch -r --contains feature/1 | grep '^\s*origin/'"${release}"'$')" ]] && echo 1 || echo 0)
	assert [ ${or_contains_f} -eq 1 ]
	same_head_r_or=$([[ $(git rev-parse ${release}) == $(git rev-parse origin/${release}) ]] && echo 1 || echo 0)
	assert [ ${same_head_r_or} -eq 1 ]
}

@test "fail updating remote release/1.0.0 from a not-feature branch" {
	release=release/1.0.0
	git branch ${release}
	git push -u origin ${release}
	git checkout -b other
	git commit -m "commit to push" --allow-empty
	# To prevent it from stopping the test on failure
	run git updatetest 1.0.0
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
	run git updatetest 1.0.0
	assert_failure
	diff_head=$([[ $(git rev-parse ${feature}) != $(git rev-parse origin/${release}) ]] && echo 1 || echo 0)
	assert [ ${diff_head} -eq 1 ]
	still_on_feature=$([[ $(git rev-parse --abbrev-ref HEAD) == ${feature} ]] && echo 1 || echo 0)
	assert [ ${still_on_feature} -eq 1 ]
}

@test "forcibly update remote release/1.0.0, even if release/1.0.1 exists" {
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
	run git updatetest 1.0.0
	assert_failure
	# To prevent it from stopping the test on failure
	run git updatetest 1.0.0 -f
	assert_failure
	git updatetest -f 1.0.0
	back_on_feature_1=$([[ $(git rev-parse --abbrev-ref HEAD) == feature/x ]] && echo 1 || echo 0)
	assert [ ${back_on_feature_1} -eq 1 ]
	or_contains_f=$([[ ! -z "$(git branch -r --contains feature/x | grep '^\s*origin/'"${release}"'$')" ]] && echo 1 || echo 0)
	assert [ ${or_contains_f} -eq 1 ]
	same_head_r_or=$([[ $(git rev-parse ${release}) == $(git rev-parse origin/${release}) ]] && echo 1 || echo 0)
	assert [ ${same_head_r_or} -eq 1 ]
}

@test "update remote release/1.0.1 from a feature" {
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
	git updatetest 1.0.1
	same_head=$([[ $(git rev-parse ${feature}) == $(git rev-parse origin/${greater_release}) ]] && echo 1 || echo 0)
	assert [ ${same_head} -eq 1 ]
}

@test "fail updating remote release/1.0.1 due to tag 1.0.1" {
	release=release/1.0.1
	feature=feature/x
	git branch ${release}
	git push -u origin ${release}
	git checkout -b ${feature}
	git commit -m "commit to push" --allow-empty
	git tag 1.0.1
	git push origin --tags
	# To prevent it from stopping the test on failure
	run git updatetest 1.0.1
	assert_failure
	diff_head=$([[ $(git rev-parse ${feature}) != $(git rev-parse origin/${release}) ]] && echo 1 || echo 0)
	assert [ ${diff_head} -eq 1 ]
	still_on_feature=$([[ $(git rev-parse --abbrev-ref HEAD) == ${feature} ]] && echo 1 || echo 0)
	assert [ ${still_on_feature} -eq 1 ]
}

@test "update the last release" {
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
	git updatetest -l
	same_head=$([[ $(git rev-parse ${feature}) == $(git rev-parse origin/${greater_release}) ]] && echo 1 || echo 0)
	assert [ ${same_head} -eq 1 ]
	still_on_feature=$([[ $(git rev-parse --abbrev-ref HEAD) == ${feature} ]] && echo 1 || echo 0)
	assert [ ${still_on_feature} -eq 1 ]
}

@test "fail updating the last release due to extra parameter" {
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
	run git updatetest -l 1.0.0
	assert_failure
	diff_head=$([[ $(git rev-parse ${feature}) != $(git rev-parse origin/${release}) ]] && echo 1 || echo 0)
	assert [ ${diff_head} -eq 1 ]
	diff_head=$([[ $(git rev-parse ${feature}) != $(git rev-parse origin/${greater_release}) ]] && echo 1 || echo 0)
	assert [ ${diff_head} -eq 1 ]
	still_on_feature=$([[ $(git rev-parse --abbrev-ref HEAD) == ${feature} ]] && echo 1 || echo 0)
	assert [ ${still_on_feature} -eq 1 ]
}

@test "forcibly update remote release/1.0.1, even if tag 1.0.1 exists" {
	release=release/1.0.1
	feature=feature/x
	git branch ${release}
	git push -u origin ${release}
	git checkout -b ${feature}
	git commit -m "commit to push" --allow-empty
	git tag 1.0.1
	git push origin --tags
	git updatetest -f -l
	same_head=$([[ $(git rev-parse ${feature}) == $(git rev-parse origin/${release}) ]] && echo 1 || echo 0)
	assert [ ${same_head} -eq 1 ]
	still_on_feature=$([[ $(git rev-parse --abbrev-ref HEAD) == ${feature} ]] && echo 1 || echo 0)
	assert [ ${still_on_feature} -eq 1 ]
}

@test "update 1.0.10 instead of 1.0.9" {
	release=release/1.0.10
	feature=feature/x
	git branch release/1.0.9
	git branch ${release}
	git push -u origin release/1.0.9
	git push -u origin ${release}
	git checkout -b ${feature}
	git commit -m "commit to push" --allow-empty
	git updatetest -l
	merged=$(git merge-base --is-ancestor ${feature} origin/${release} && echo 1 || echo 0)
	assert_equal ${merged} 1
}
