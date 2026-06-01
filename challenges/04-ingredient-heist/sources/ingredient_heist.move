// Copyright (c) 2025 IOTA Stiftung
// SPDX-License-Identifier: Apache-2.0

/// Challenge 4 — Ingredient Heist
///
/// The legendary chef will only reward a flag for one exact recipe. To assemble it
/// you `open_order`, season it with four amounts, and `get_flag` — all in a single
/// transaction.
///
/// Why one transaction? `Order` is a **hot potato**: a struct with NO abilities. You
/// can't store it, copy it, or drop it. Once `open_order` hands you one, your only
/// legal move is to thread it through the seasoning functions and finally into
/// `get_flag`, which destroys it. If you try to call `open_order` on its own, the
/// transaction won't even build — there's nothing valid you can do with the leftover
/// `Order`. That forces you to compose a **Programmable Transaction Block (PTB)**.
///
/// The chef checks your recipe by its exact **BCS** serialization. Read
/// `EXPECTED_RECIPE` below and work out the four amounts that serialize to it.
///
/// Concepts: PTBs, the hot-potato pattern, and BCS serialization.
module ingredient_heist::ingredient_heist;

use iota::bcs;
use iota::event;

// === Errors ===

#[error(code = 0)]
const EWrongRecipe: vector<u8> = b"That is not the chef's secret recipe.";

// === Constants ===

/// The chef accepts exactly the recipe whose `bcs::to_bytes` equals these bytes.
/// (Hint: the four fields are `u16`s, serialized in order, little-endian.)
const EXPECTED_RECIPE: vector<u8> = x"390564000100e803";

// === Structs ===

/// The four seasoning amounts. BCS serializes the fields in declaration order;
/// each `u16` becomes two little-endian bytes.
public struct Recipe has drop {
    flour: u16,
    water: u16,
    yeast: u16,
    salt: u16,
}

/// A HOT POTATO: no `key`, `store`, `copy`, or `drop`. It cannot leave the
/// transaction it was born in — it must be consumed by `get_flag`.
public struct Order {
    recipe: Recipe,
}

public struct Flag has key, store {
    id: UID,
    student: address,
}

public struct FlagCaptured has copy, drop {
    flag_id: ID,
    student: address,
}

// === Public functions (chain these in a PTB) ===

/// Begin an order with all amounts at zero. Returns a hot potato.
public fun open_order(): Order {
    Order { recipe: Recipe { flour: 0, water: 0, yeast: 0, salt: 0 } }
}

public fun set_flour(mut order: Order, amount: u16): Order {
    order.recipe.flour = amount;
    order
}

public fun set_water(mut order: Order, amount: u16): Order {
    order.recipe.water = amount;
    order
}

public fun set_yeast(mut order: Order, amount: u16): Order {
    order.recipe.yeast = amount;
    order
}

public fun set_salt(mut order: Order, amount: u16): Order {
    order.recipe.salt = amount;
    order
}

/// Hand the finished order to the chef. If its BCS bytes match the secret recipe,
/// you get the flag; otherwise the whole transaction reverts.
public fun get_flag(order: Order, ctx: &mut TxContext) {
    // Consume the hot potato.
    let Order { recipe } = order;

    assert!(bcs::to_bytes(&recipe) == EXPECTED_RECIPE, EWrongRecipe);

    let student = ctx.sender();
    let flag = Flag { id: object::new(ctx), student };
    event::emit(FlagCaptured { flag_id: object::id(&flag), student });
    transfer::public_transfer(flag, student);
}
