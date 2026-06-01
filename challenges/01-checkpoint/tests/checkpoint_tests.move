// Copyright (c) 2025 IOTA Stiftung
// SPDX-License-Identifier: Apache-2.0

#[test_only]
module checkpoint::checkpoint_tests;

use checkpoint::checkpoint::{Self, Flag};
use iota::test_scenario as ts;

/// The flag is captured when, after calling `get_flag`, the caller owns a `Flag`.
/// This test fails while `get_flag` still aborts, and passes once you implement it.
#[test]
fun student_captures_flag() {
    let student = @0xCAFE;

    let mut scenario = ts::begin(student);
    // Transaction 1: call the function under test.
    checkpoint::get_flag(scenario.ctx());

    // Transaction 2: check the student now owns exactly one Flag.
    scenario.next_tx(student);
    assert!(scenario.has_most_recent_for_sender<Flag>(), 0);
    let flag = scenario.take_from_sender<Flag>();
    scenario.return_to_sender(flag);

    scenario.end();
}
