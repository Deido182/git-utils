#!/usr/bin/env bats

root_dir="$(git rev-parse --show-toplevel)"
test_repo="${root_dir}/test-repo"

# Run before each test; this function must be unique and all tests should source this file
setup() {
    DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
    # Make executables in commands/ visible to PATH
    PATH="$DIR/../commands:$PATH"
    
    # Setup new test-repo
    rm -r ${test_repo}
	cd ${test_repo}
	git init
	
	# Load std test utils
	load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'
}
