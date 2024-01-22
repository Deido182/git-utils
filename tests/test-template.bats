#!/usr/bin/env bats

# git submodule add https://github.com/bats-core/bats-core.git test/bats
# git submodule add https://github.com/bats-core/bats-support.git test/test_helper/bats-support
# git submodule add https://github.com/bats-core/bats-assert.git test/test_helper/bats-assert
# git submodule update --init

curr_dir="$(pwd)"
root_dir="$(git rev-parse --show-toplevel)"
. "${root_dir}/containerized-commands/container-context/commands/libs/common-functions-and-constants"

test_repo="${tmp_dir}/test-repo"
mocked_remote="${tmp_dir}/mocked-remote"
user_name="Test Name"
user_email="test@name.com"

# Run before each test; this function must be unique and all tests should source this file
setup() {
    DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" >/dev/null 2>&1 && pwd)"
    # Make executables in commands/ visible to PATH
    PATH="$DIR/../commands:$PATH"
    # To hide the installed ones (that are not the ones to be tested)
    if [[ -d "${root_dir}/${installed_commands_basename}" ]]; then
        mv "${root_dir}/${installed_commands_basename}" "${root_dir}/.${installed_commands_basename}"
    fi

    # Setup new test-repo
    create_repo ${test_repo} "${user_name}" "${user_email}"
    cd ${curr_dir}
    # Add mocked remote
    create_repo ${mocked_remote} "${user_name}" "${user_email}"
    git config receive.denyCurrentBranch ignore
    cd ${test_repo}
    git remote add origin "file://${mocked_remote}/.git"
    git push --force -u origin master

    # Load std test utils
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'
}

# Run after each test; this function must be unique and all tests should source this file
teardown() {
    cd ${curr_dir}
    remove_repo ${test_repo}
    remove_repo ${mocked_remote}
    if [[ -d "${root_dir}/.${installed_commands_basename}" ]]; then
        mv "${root_dir}/.${installed_commands_basename}" "${root_dir}/${installed_commands_basename}"
    fi
}
