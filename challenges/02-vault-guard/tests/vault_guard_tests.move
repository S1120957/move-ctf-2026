// Copyright (c) 2025 IOTA Stiftung
// SPDX-License-Identifier: Apache-2.0

#[test_only]
module vault_guard::vault_guard_tests;

use iota::test_scenario as ts;
use vault_guard::vault_guard::{Self, Vault, Flag};

/// Dial the combination to exactly TARGET (1337), across two transactions, then
/// capture the flag. Demonstrates that shared-object state persists between txs.
#[test]
fun cracks_the_vault() {
    let student = @0xBEEF;
    let mut scenario = ts::begin(student);

    // Publish: creates and shares the Vault.
    vault_guard::init_for_testing(scenario.ctx());

    // Tx 1: turn the dial to 1000.
    scenario.next_tx(student);
    {
        let mut vault = scenario.take_shared<Vault>();
        vault_guard::turn(&mut vault, 1000);
        ts::return_shared(vault);
    };

    // Tx 2: turn 337 more (1000 + 337 == 1337) and grab the flag.
    scenario.next_tx(student);
    {
        let mut vault = scenario.take_shared<Vault>();
        vault_guard::turn(&mut vault, 337);
        assert!(vault_guard::dial(&vault) == 1337, 1);
        vault_guard::get_flag(&mut vault, scenario.ctx());
        ts::return_shared(vault);
    };

    // The student now owns a Flag.
    scenario.next_tx(student);
    {
        assert!(scenario.has_most_recent_for_sender<Flag>(), 2);
        let flag = scenario.take_from_sender<Flag>();
        scenario.return_to_sender(flag);
    };

    scenario.end();
}

/// Calling get_flag on the wrong combination must abort.
#[test]
#[expected_failure(abort_code = vault_guard::EWrongCombination)]
fun wrong_combination_aborts() {
    let student = @0xBEEF;
    let mut scenario = ts::begin(student);
    vault_guard::init_for_testing(scenario.ctx());

    scenario.next_tx(student);
    {
        let mut vault = scenario.take_shared<Vault>();
        vault_guard::turn(&mut vault, 1); // dial = 1, not 1337
        vault_guard::get_flag(&mut vault, scenario.ctx());
        ts::return_shared(vault);
    };

    scenario.end();
}
