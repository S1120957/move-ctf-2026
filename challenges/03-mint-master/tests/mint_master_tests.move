// Copyright (c) 2025 IOTA Stiftung
// SPDX-License-Identifier: Apache-2.0

// These tests document how the contract BEHAVES. They do not solve the challenge
// for you — capturing the flag is something you do from the command line (see the
// README). Run them with `iota move test` to confirm your understanding.
#[test_only]
module mint_master::mint_master_tests;

use iota::coin::{Coin, TreasuryCap};
use iota::test_scenario as ts;
use mint_master::mint_master::{Self, MINT_MASTER};

/// Every `mint` call yields a coin worth exactly 2.
#[test]
fun mint_gives_two() {
    let user = @0xA;
    let mut scenario = ts::begin(user);
    mint_master::init_for_testing(scenario.ctx());

    scenario.next_tx(user);
    {
        let mut treasury = scenario.take_shared<TreasuryCap<MINT_MASTER>>();
        mint_master::mint(&mut treasury, scenario.ctx());
        ts::return_shared(treasury);
    };

    scenario.next_tx(user);
    {
        let coin = scenario.take_from_sender<Coin<MINT_MASTER>>();
        assert!(coin.value() == 2, 0);
        scenario.return_to_sender(coin);
    };

    scenario.end();
}

/// Handing `get_flag` the wrong amount (a freshly minted 2) is rejected.
#[test]
#[expected_failure(abort_code = mint_master::EWrongAmount)]
fun wrong_amount_is_rejected() {
    let user = @0xA;
    let mut scenario = ts::begin(user);
    mint_master::init_for_testing(scenario.ctx());

    scenario.next_tx(user);
    {
        let mut treasury = scenario.take_shared<TreasuryCap<MINT_MASTER>>();
        mint_master::mint(&mut treasury, scenario.ctx());
        ts::return_shared(treasury);
    };

    scenario.next_tx(user);
    {
        let coin = scenario.take_from_sender<Coin<MINT_MASTER>>();
        mint_master::get_flag(coin, scenario.ctx()); // value is 2, not 5 -> aborts
    };

    scenario.end();
}
