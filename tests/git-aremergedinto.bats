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
    ans=$(git aremergedinto -n "${feature2_name}" -u "${url1}" -u "${url2}" -n "${feature1_name}" master)
    [[ "$(echo ${ans} | grep -o ERROR | wc -l)" == 1 ]] && [[ "$(echo ${ans} | grep -o WARNING | wc -l)" == 2 ]] && ok=Y || ok=N
    remove_repo ${repo1}
    remove_repo ${repo2}
    assert [ ${ok} = "Y" ]
}

@test "assess there is a feature that has not been merged, with multithreading enabled" {
    feature1_name=test-1
    feature2_name=test-2
    repo1="${tmp_dir}/test-aremergedinto-repo-1"
    repo2="${tmp_dir}/test-aremergedinto-repo-2"
    repo3="${tmp_dir}/test-aremergedinto-repo-3"
    repo4="${tmp_dir}/test-aremergedinto-repo-4"
    create_repo ${repo1}
    create_repo ${repo2}
    create_repo ${repo3}
    create_repo ${repo4}
    url1="file://${repo1}/.git"
    url2="file://${repo2}/.git"
    url3="file://${repo3}/.git"
    url4="file://${repo4}/.git"
    cd ${repo1}
    git checkout -b "feature/${feature1_name}"
    git commit -m "Commit" --allow-empty
    git checkout master
    git merge "feature/${feature1_name}"
    cd ${repo3}
    git checkout -b "feature/${feature2_name}"
    echo "test" > test.txt
    git add --all
    git commit -m "Commit"
    git checkout master
    git merge "feature/${feature2_name}"
    cd ${repo4}
    git checkout -b "feature/${feature2_name}"
    git commit -m "Commit" --allow-empty
    ans=$(git aremergedinto -m -u "${url1}" -u "${url2}" -u "${url3}" -u "${url4}" -n "${feature1_name}" -n "${feature2_name}" master)
    [[ "$(echo ${ans} | grep -o ERROR | wc -l)" == 1 ]] && [[ "$(echo ${ans} | grep -o WARNING | wc -l)" == 5 ]] && ok=Y || ok=N
    remove_repo ${repo1}
    remove_repo ${repo2}
    remove_repo ${repo3}
    remove_repo ${repo4}
    assert [ ${ok} = "Y" ]
}
