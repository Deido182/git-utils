#!/usr/bin/env bats

# git submodule add https://github.com/bats-core/bats-core.git test/bats
# git submodule add https://github.com/bats-core/bats-support.git test/test_helper/bats-support
# git submodule add https://github.com/bats-core/bats-assert.git test/test_helper/bats-assert
# git submodule update --init

curr_dir="$(pwd)"
root_dir="$(git rev-parse --show-toplevel)"
test_repo="/tmp/$(basename ${root_dir})/test-repo"

remove_test_repo() {
	if [ -d "${test_repo}" ]; then
		rm -r ${test_repo}
	fi
}

# Run before each test; this function must be unique and all tests should source this file
setup() {
    DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
    # Make executables in commands/ visible to PATH
    PATH="$DIR/../commands:$PATH"
    
    # Setup new test-repo
    remove_test_repo
	cd ${test_repo}
	git init
	
	# Load std test utils
	load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'
}

# Run after each test; this function must be unique and all tests should source this file
teardown() {
	cd ${curr_dir}
    remove_test_repo
}