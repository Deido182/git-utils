#!/usr/bin/env bats

# The bats version of 'source'
load test-template.bats

@test "test the split function" {
    str="el 1..el 2..el 4..el 1"
    split "${str}" ".." tokens
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

@test "test the expand function" {
    arr=("a b" "c" "d . e" 1)
    IFS=$'\n' new_arr=($(expand arr))
    unset IFS
    ok=$([[ \
        ${#new_arr[@]} == 4 \
        && ${new_arr[0]} == "a b" \
        && ${new_arr[1]} == "c" \
        && ${new_arr[2]} == "d . e" \
        && ${new_arr[3]} == 1
    ]] && echo 1 || echo 0)
    assert [ ${ok} -eq 1 ]
}

@test "test the sort_array function" {
    arr=(7 4 11 8 8 7 1)
    sort_array arr
    # They are strings by default
    ok=$([[ ${#arr[@]} == 7 && ${arr[@]} == "1 11 4 7 7 8 8" ]] && echo 1 || echo 0)
    assert [ ${ok} -eq 1 ]

    arr=(7 4 11 8 8 7 1)
    sort_array -n arr
    ok=$([[ ${#arr[@]} == 7 && ${arr[@]} == "1 4 7 7 8 8 11" ]] && echo 1 || echo 0)
    assert [ ${ok} -eq 1 ]

    arr=(7 4 11 8 8 7 1)
    sort_array -nr arr
    ok=$([[ ${#arr[@]} == 7 && ${arr[@]} == "11 8 8 7 7 4 1" ]] && echo 1 || echo 0)
    assert [ ${ok} -eq 1 ]

    arr=("Peter Parker" "Peter Paarker" "Peter Pabrker" "Peter Parker 2")
    sort_array arr
    ok=$([[ ${#arr[@]} == 4 && ${arr[@]} == "Peter Paarker Peter Pabrker Peter Parker Peter Parker 2" ]] && echo 1 || echo 0)
    assert [ ${ok} -eq 1 ]
}

@test "test the drop_duplicates function" {
    arr=(7 4 11 8 8 7 1)
    drop_duplicates arr
    ok=$([[ ${#arr[@]} == 5 && ${arr[@]} == "1 11 4 7 8" ]] && echo 1 || echo 0)
    assert [ ${ok} -eq 1 ]

    arr=("Peter Parker" "Peter Paarker" "Peter Parker" "Peter Parker 2" "Peter Paarker")
    drop_duplicates arr
    ok=$([[ ${#arr[@]} == 3 && ${arr[@]} == "Peter Paarker Peter Parker Peter Parker 2" ]] && echo 1 || echo 0)
    assert [ ${ok} -eq 1 ]
}

@test "test the index_of function" {
    arr=(7 4 11 8 8 7 1)
    index7=$(index_of arr 7)
    ok=$([[ ${index7} == 0 ]] && echo 1 || echo 0)
    assert [ ${ok} -eq 1 ]
    index9=$(index_of arr 9)
    ok=$([[ ${index9} == -1 ]] && echo 1 || echo 0)
    assert [ ${ok} -eq 1 ]

    arr=("Peter Parker" "Peter Paarker" "Peter Parker" "Peter Parker 2" "Peter Paarker")
    index=$(index_of arr "Peter Paarker")
    ok=$([[ ${index} == 1 ]] && echo 1 || echo 0)
    assert [ ${ok} -eq 1 ]
}
