// Copyright (c) 2025 IOTA Stiftung
// SPDX-License-Identifier: Apache-2.0

/// Challenge 1 — Checkpoint
///
/// Welcome! Your very first task is to mint yourself a `Flag`.
///
/// Every challenge in this workshop ends the same way: you make a `get_flag`
/// function succeed and end up owning a `Flag` object. Here there is no puzzle —
/// the point is to get comfortable with a Move module, objects, and the
/// `iota move build` / `iota move test` workflow.
///
/// YOUR TASK: implement the body of `get_flag` so the test in
/// `tests/checkpoint_tests.move` passes.
module checkpoint::checkpoint;

use iota::event;

// === Errors ===

#[error(code = 0)]
const ENotImplemented: vector<u8> = b"get_flag is not implemented yet - this is your job!";

// === Structs ===

/// The prize. An object with the `key` ability lives on-chain and is owned by
/// an address; `store` lets it be transferred with the generic transfer API.
public struct Flag has key, store {
    id: UID,
    student: address,
}

/// Emitted whenever a flag is captured. Events are the standard way for an
/// off-chain observer (like the workshop scoreboard) to notice a capture.
public struct FlagCaptured has copy, drop {
    flag_id: ID,
    student: address,
}

// === Entry functions ===

/// Mint a `Flag` to whoever calls this function.
public entry fun get_flag(ctx: &mut TxContext) {
    // The address that signed/sent this transaction.
    let _student = ctx.sender();

    // TODO(challenge 1): implement the three steps below, then delete the
    // `abort` line.
    //
    //   1. Create the flag object:
    //        let flag = Flag { id: object::new(ctx), student: _student };
    //   2. Announce the capture by emitting an event:
    //        event::emit(FlagCaptured { flag_id: object::id(&flag), student: _student });
    //   3. Give the flag to the caller:
    //        transfer::public_transfer(flag, _student);
    //
    // Hint: `event` is already imported above; `object` and `transfer` come
    // from the framework and are always in scope.
    abort ENotImplemented
}
