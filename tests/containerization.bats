#!/usr/bin/env bats

# The bats version of 'source'
load test-template.bats

run_containerized="${root_dir}/containerized-commands/container-setup/run-containerized"

# bats file_tags=tag:containerized-only

@test "test the containerized environment" {
    assert_equal "$(${run_containerized} 'git rev-parse --is-inside-work-tree')" "true"
    assert_equal "$(${run_containerized} 'git config --get user.name')" "${user_name}"
    assert_equal "$(${run_containerized} 'git config --get user.email')" "${user_email}"
    other_name="Other Name"
    other_email="other@email.com"
    git config --global user.name "${other_name}"
    git config --global user.email "${other_email}"
    # Still the same
    assert_equal "$(${run_containerized} 'git config --get user.name')" "${user_name}"
    assert_equal "$(${run_containerized} 'git config --get user.email')" "${user_email}"
    git config --unset user.name
    git config --unset user.email
    # Updated
    assert_equal "$(${run_containerized} 'git config --get user.name')" "${other_name}"
    assert_equal "$(${run_containerized} 'git config --get user.email')" "${other_email}"
}
