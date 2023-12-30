#!/usr/bin/env bats

# The bats version of 'source'
load test-template.bats

@test "fail due to missing 'into' branch" {
    run git aremergedinto
    assert_failure
}

@test "assess the feature has been correctly merged into master, on both repositories" {
    feature_name=test
    repo1="${tmp_dir}/test-aremergedinto-repo-1"
    repo2="${tmp_dir}/test-aremergedinto-repo-2"
    create_repo ${repo1}
    create_repo ${repo2}
    url1="file://${repo1}/.git"
    url2="file://${repo2}/.git"
    echo "---> ${repo1} ${repo2}"
    cd ${repo1}
    git checkout -b "feature/${feature_name}"
    git commit -m "Commit" --allow-empty
    git checkout master
    git merge "feature/${feature_name}"
    git aremergedinto -u "${url1}" -u "${url2}" -n "${feature_name}" master
    #assert_failure
}
