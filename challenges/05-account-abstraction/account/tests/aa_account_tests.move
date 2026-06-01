// Copyright (c) 2025 IOTA Stiftung
// SPDX-License-Identifier: Apache-2.0

// Behavior test for the flag gate. The *positive* path (capturing the flag) can
// only be exercised on a live network, because it requires a transaction to run AS
// the abstract account — see the README. Here we confirm the gate rejects anyone
// who is not the account.
#[test_only]
module aa_account::aa_account_tests;

use aa_account::aa_account::{Self, AaAccount};
use iota::test_scenario as ts;

#[test]
#[expected_failure(abort_code = aa_account::ENotTheAccount)]
fun get_flag_rejects_non_account_sender() {
    let attacker = @0xBAD;
    let pubkey = x"0000000000000000000000000000000000000000000000000000000000000000";

    let mut scenario = ts::begin(attacker);
    aa_account::share_for_testing(pubkey, scenario.ctx());

    scenario.next_tx(attacker);
    let account = scenario.take_shared<AaAccount>();
    // attacker's address != the account's address -> aborts.
    aa_account::get_flag(&account, scenario.ctx());
    ts::return_shared(account);

    scenario.end();
}
