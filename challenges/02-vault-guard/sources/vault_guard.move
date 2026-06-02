// Copyright (c) 2025 IOTA Stiftung
// SPDX-License-Identifier: Apache-2.0

/// Challenge 2 — Vault Guard
///
/// A single combination lock guards the flag. Unlike Challenge 1's `Flag` (which
/// you owned), the `Vault` is a *shared* object: anyone can grab a mutable
/// reference to it and turn its dial. Its state persists between transactions.
///
/// The dial starts at 0. Each `turn` adds to it and costs one attempt. When the
/// dial reads exactly `TARGET`, `get_flag` will hand over the prize.
///
/// YOUR TASK: implement `turn` and `get_flag` so the tests pass. You'll practise
/// mutating shared state through `&mut`, enforcing rules with `assert!`, and using
/// custom error codes.
#[allow(lint(self_transfer))]
module vault_guard::vault_guard;

use iota::event;

// === Errors ===

#[error(code = 0)]
const ETooManyAttempts: vector<u8> = b"The vault has locked you out - too many turns.";
#[error(code = 1)]
const EWrongCombination: vector<u8> = b"The dial is not on the target combination.";
#[error(code = 2)]
const ENotImplemented: vector<u8> = b"This function is not implemented yet - that's your job!";

// === Constants ===

/// The dial must read exactly this to open the vault.
const TARGET: u64 = 1337;
/// The vault locks up after this many turns.
const MAX_ATTEMPTS: u64 = 100;

// === Structs ===

/// A shared combination lock. `key` (no `store`) + `share_object` makes it a
/// shared object anyone can reference mutably.
public struct Vault has key {
    id: UID,
    dial: u64,
    attempts: u64,
}

public struct Flag has key, store {
    id: UID,
    student: address,
}

public struct FlagCaptured has copy, drop {
    flag_id: ID,
    student: address,
}

// === Init ===

/// Runs once when the package is published: creates the vault and shares it.
fun init(ctx: &mut TxContext) {
    transfer::share_object(Vault { id: object::new(ctx), dial: 0, attempts: 0 });
}

// === Entry / public functions ===

/// Turn the dial by `clicks`. Each call costs one attempt.
public fun turn(vault: &mut Vault, clicks: u64) {
    // TODO(challenge 2):
    //   1. If `vault.attempts >= MAX_ATTEMPTS`, abort with `ETooManyAttempts`.
    //      (use `assert!(condition, ETooManyAttempts)`)
    //   2. Increment `vault.attempts` by 1.
    //   3. Add `clicks` to `vault.dial`.
    // Then delete the abort below.
    assert!(vault.attempts < MAX_ATTEMPTS, ETooManyAttempts);
    vault.attempts = vault.attempts + 1;
    vault.dial = vault.dial + clicks;
}

/// Capture the flag — but only if the dial reads exactly `TARGET`.
public entry fun get_flag(vault: &mut Vault, ctx: &mut TxContext) {
    // TODO(challenge 2):
    //   1. abort with `EWrongCombination` unless `vault.dial == TARGET`.
    //   2. call `award_flag(ctx)` to mint and send the flag.
    // Then delete the abort below.
    // let _ = vault;
    assert!(vault.dial == TARGET, EWrongCombination);
    award_flag(ctx);
}

// === Helpers (given) ===

/// Mints a `Flag` to the caller and announces it. You wrote this in Challenge 1.
fun award_flag(ctx: &mut TxContext) {
    let student = ctx.sender();
    let flag = Flag { id: object::new(ctx), student };
    event::emit(FlagCaptured { flag_id: object::id(&flag), student });
    transfer::public_transfer(flag, student);
}

// === View functions ===

public fun dial(vault: &Vault): u64 { vault.dial }

public fun attempts(vault: &Vault): u64 { vault.attempts }

// === Test-only ===

#[test_only]
public fun init_for_testing(ctx: &mut TxContext) { init(ctx) }