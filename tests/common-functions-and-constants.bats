#!/usr/bin/env bats

# The bats version of 'source'
load test-template.bats

@test "test the split function" {
    str="el 1..el 2..el 4..el 1"
    tokens=()
    split "${str}" ".." tokens
    echo "---> ${tokens[@]} ${#tokens[@]}"
    ok=$([[ \
        ${#tokens[@]} == 4 \
        && ${tokens[0]} == ${tokens[3]} \
        && ${tokens[1]} == "el 2" \
        && ${tokens[2]} == "el 4"
    ]] && echo 1 || echo 0)
    assert [ ${ok} -eq 1 ]
}

@test "test the require_confirmation function" {
    require_confirmation "info-text" <<< 1
    run require_confirmation "info-text" <<< 2
    assert_failure
}

@test "test the sort_array function" {
    # TODO: add test with -n option and elements with spaces
    arr=(7 4 11 8 8 7 1)
    sorted=($(sort_array ${arr[@]}))
    # They are strings by default
    ok=$([[ ${sorted[@]} == "1 11 4 7 7 8 8" ]] && echo 1 || echo 0)
    assert [ ${ok} -eq 1 ]
}

@test "test the drop_duplicates function" {
    # TODO: add test with elements with spaces
    arr=(7 4 11 8 8 7 1)
    cleaned=($(drop_duplicates ${arr[@]}))
    ok=$([[ ${cleaned[@]} == "1 11 4 7 8" ]] && echo 1 || echo 0)
    assert [ ${ok} -eq 1 ]
}

@test "test the index_of function" {
    # TODO: add test with elements with spaces
    arr=(7 4 11 8 8 7 1)
    index7=($(index_of ${arr[@]} 7))
    ok=$([[ ${index7} == 0 ]] && echo 1 || echo 0)
    assert [ ${ok} -eq 1 ]
    index9=($(index_of ${arr[@]} 9))
    ok=$([[ ${index9} == -1 ]] && echo 1 || echo 0)
    assert [ ${ok} -eq 1 ]
}
