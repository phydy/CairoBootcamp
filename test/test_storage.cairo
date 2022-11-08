%lang starknet
from exercises.contracts.storage.storage import get_balance, set_balance
from starkware.cairo.common.cairo_builtins import HashBuiltin

@external
func test_get_balance{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    let (balance) = get_balance();
    assert 0 = balance;

    return ();
}

@external
func test_set_balance{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    set_balance(42);
    let (balance) = get_balance();
    assert 42 = balance;

    set_balance(-8);
    let (balance) = get_balance();
    assert -8 = balance;

    return ();
}

const MINT_ADMIN = 0x00348f5537be66815eb7de63295fcb5d8b8b2ffe09bb712af4966db7cbb04a91;
const TEST_ACC1 = 0x00348f5537be66815eb7de63295fcb5d8b8b2ffe09bb712af4966db7cbb04a95;
const TEST_ACC2 = 0x3fe90a1958bb8468fb1b62970747d8a00c435ef96cda708ae8de3d07f1bb56b;

@external 
func __setup__() {
    
     %{
        context.contract_a_address  = deploy_contract("./exercises/contracts/storage/storage.cairo", [
                ids.MINT_ADMIN
               ]).contract_address
    %}

    return ();
}

@external
func test_set_balance_ac{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    
) {
    tempvar contract_address;
    %{ ids.contract_address = context.contract_a_address %}

    //%{ expect_revert("TRANSACTION_FAILED", "Ownable: caller is not the owner") %}
    %{ stop_prank_callable = start_prank(ids.MINT_ADMIN, ids.contract_address) %}
    set_balance(20);
    %{ stop_prank_callable() %}

    return ();
}

@external
func test_prank_set_balance_ac{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
) {
    tempvar contract_address;
    %{ ids.contract_address = context.contract_a_address %}

    %{ stop_prank_callable = start_prank(ids.TEST_ACC2, ids.contract_address) %}
    %{ expect_revert("TRANSACTION_FAILED", "Ownable: caller is not the owner") %}
    set_balance(20);
    %{ stop_prank_callable() %}
    
    return ();
}