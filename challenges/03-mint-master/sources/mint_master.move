// Copyright (c) 2025 IOTA Stiftung
// SPDX-License-Identifier: Apache-2.0

/// Challenge 3 — Mint Master
///
/// This is your first *interaction* challenge. The contract below is already
/// deployed and you may NOT change it — your job is to read it, then drive it from
/// the command line until `get_flag` succeeds.
///
/// The shop sells its own coin, `MINT`. A shared `TreasuryCap` lets anyone mint,
/// but every `mint` call gives you a coin worth exactly 2. The vending machine
/// (`get_flag`) only accepts a single coin worth EXACTLY 5. Two doesn't divide
/// five — so you'll have to mint a few coins, `join` them, and `split` off the
/// precise amount.
///
/// Concepts: the Coin standard, one-time witnesses, `TreasuryCap`, and the
/// `join` / `split` coin operations.
module mint_master::mint_master;

use iota::coin::{Self, Coin, TreasuryCap};
use iota::event;

// === Errors ===

#[error(code = 0)]
const EWrongAmount: vector<u8> = b"The machine only accepts a coin worth EXACTLY 5 MINT.";

// === Constants ===

/// `get_flag` demands a coin of exactly this value.
const TARGET: u64 = 5;
/// Each `mint` call produces a coin worth this much.
const MINT_AMOUNT: u64 = 2;

// === Structs ===

/// One-time witness: a struct named after the module in UPPERCASE, with only
/// `drop`. The VM hands exactly one of these to `init` at publish, which is how
/// `create_currency` guarantees the currency is created only once.
public struct MINT_MASTER has drop {}

public struct Flag has key, store {
    id: UID,
    student: address,
}

public struct FlagCaptured has copy, drop {
    flag_id: ID,
    student: address,
}

// === Init ===

/// Creates the `MINT` currency at publish and shares the `TreasuryCap` so anybody
/// can mint.
fun init(witness: MINT_MASTER, ctx: &mut TxContext) {
    let (treasury, metadata) = coin::create_currency(
        witness,
        0,
        b"MINT",
        b"MintMaster Coin",
        b"Mint, join, and split me until I am worth exactly 5.",
        option::none(),
        ctx,
    );
    transfer::public_freeze_object(metadata);
    transfer::public_share_object(treasury);
}

// === Public functions ===

/// Mint a single `MINT` coin worth `MINT_AMOUNT` (2) and send it to the caller.
public fun mint(treasury: &mut TreasuryCap<MINT_MASTER>, ctx: &mut TxContext) {
    let coin = coin::mint(treasury, MINT_AMOUNT, ctx);
    transfer::public_transfer(coin, ctx.sender());
}

/// Permanently destroy a coin — useful if you over-mint.
public fun burn(treasury: &mut TreasuryCap<MINT_MASTER>, coin: Coin<MINT_MASTER>): u64 {
    coin::burn(treasury, coin)
}

/// Pay a coin worth EXACTLY 5 `MINT` to capture the flag. Your coin is returned.
public entry fun get_flag(coin: Coin<MINT_MASTER>, ctx: &mut TxContext) {
    assert!(coin::value(&coin) == TARGET, EWrongAmount);

    let student = ctx.sender();
    // Hand the coin back — the machine only needed to inspect it.
    transfer::public_transfer(coin, student);

    let flag = Flag { id: object::new(ctx), student };
    event::emit(FlagCaptured { flag_id: object::id(&flag), student });
    transfer::public_transfer(flag, student);
}

// === Test-only ===

/// Shares a `TreasuryCap<MINT_MASTER>` for unit tests, bypassing the one-time
/// witness requirement of `create_currency` (which only holds at real publish).
#[test_only]
public fun init_for_testing(ctx: &mut TxContext) {
    transfer::public_share_object(coin::create_treasury_cap_for_testing<MINT_MASTER>(ctx));
}
