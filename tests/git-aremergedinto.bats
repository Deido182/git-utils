#!/usr/bin/env bats

# The bats version of 'source'
load test-template.bats

@test "fail due to missing 'into' branch" {
    run git aremergedinto
    assert_failure
}

@test "assess the feature either does not exist, or has been correctly merged into master, on both repositories" {
    feature_name=test
    repo1="${tmp_dir}/test-aremergedinto-repo-1"
    repo2="${tmp_dir}/test-aremergedinto-repo-2"
    create_repo ${repo1}
    create_repo ${repo2}
    url1="file://${repo1}/.git"
    url2="file://${repo2}/.git"
    cd ${repo1}
    git checkout -b "feature/${feature_name}"
    git commit -m "Commit" --allow-empty
    git checkout master
    git merge "feature/${feature_name}"
    ans=$(git aremergedinto -u "${url1}" -u "${url2}" -n "${feature_name}" master)
    [[ "$(echo ${ans} | grep -o ERROR)" == "" ]] && [[ "$(echo ${ans} | grep -o WARNING | wc -l)" == 1 ]] && ok=Y || ok=N
    remove_repo ${repo1}
    remove_repo ${repo2}
    assert [ ${ok} = "Y" ]
}

@test "assess there is a feature that has not been merged" {
    feature1_name=test-1
    feature2_name=test-2
    repo1="${tmp_dir}/test-aremergedinto-repo-1"
    repo2="${tmp_dir}/test-aremergedinto-repo-2"
    create_repo ${repo1}
    create_repo ${repo2}
    url1="file://${repo1}/.git"
    url2="file://${repo2}/.git"
    cd ${repo1}
    git checkout -b "feature/${feature1_name}"
    git commit -m "Commit" --allow-empty
    git checkout master
    git merge "feature/${feature1_name}"
    cd ${repo2}
    git checkout -b "feature/${feature2_name}"
    git commit -m "Commit" --allow-empty
    git aremergedinto -n "${feature2_name}" -u "${url1}" -u "${url2}" -n "${feature1_name}" master
    ans=$(git aremergedinto -n "${feature2_name}" -u "${url1}" -u "${url2}" -n "${feature1_name}" master)
    [[ "$(echo ${ans} | grep -o ERROR | wc -l)" == 1 ]] && [[ "$(echo ${ans} | grep -o WARNING | wc -l)" == 2 ]] && ok=Y || ok=N
    remove_repo ${repo1}
    remove_repo ${repo2}
    assert [ ${ok} = "Y" ]
}
