#!/usr/bin/env bats

# The bats version of 'source'
load test-template.bats

@test "fail due to missing 'into' branch" {
    run git aremergedinto -l develop
    assert_failure
}
