# Challenge 4 — Ingredient Heist

> **Difficulty:** ⭐⭐⭐⭐ · **Mode:** interact (don't modify the contract) · **Goal:** compose one perfect transaction

## Story

The chef guards a flag behind a single secret recipe. To present it you must
`open_order`, set four seasoning amounts, and `get_flag` — and you must do it all in
**one transaction**. There's no way to keep a half-finished order between
transactions, because an `Order` is a *hot potato*.

## What you'll learn

- **The hot-potato pattern:** a struct with **no abilities** (`Order`). It can't be
  stored, copied, or dropped — only passed along and finally consumed. This forces a
  specific sequence of calls *within a single transaction*.
- **Programmable Transaction Blocks (PTBs):** chaining several Move calls with
  `iota client ptb`, threading the result of one command into the next with
  `--assign`.
- **BCS serialization:** the chef compares your recipe to a fixed byte string. You'll
  decode those bytes back into the numbers you need.

## The rules

The deployed contract is in
[`sources/ingredient_heist.move`](sources/ingredient_heist.move). **Don't modify it.**
The functions are designed to be chained:

```
open_order() -> Order
set_flour(Order, u16) -> Order      (also set_water / set_yeast / set_salt)
get_flag(Order)                     consumes the Order; flag iff recipe is exact
```

## Step 1 — decode the recipe

The contract accepts exactly:

```move
const EXPECTED_RECIPE: vector<u8> = x"390564000100e803";
```

The recipe is four `u16` fields (`flour, water, yeast, salt`), serialized in order,
**little-endian** (each `u16` is two bytes, least-significant first). Split the 8
bytes into four pairs and convert each pair back into a number. (See the hint if you
get stuck.)

## Step 2 — compose the PTB

This challenge is already deployed for you. Run `scripts/deploy-all.sh` and
`source .workshop.env` (see the [top-level README](../../README.md#getting-started)) to
set `$PKG4`. Then replace the four `<...>` placeholders with the amounts you decoded:

```bash
iota client ptb \
  --move-call $PKG4::ingredient_heist::open_order              --assign o0 \
  --move-call $PKG4::ingredient_heist::set_flour o0 <FLOUR>    --assign o1 \
  --move-call $PKG4::ingredient_heist::set_water o1 <WATER>    --assign o2 \
  --move-call $PKG4::ingredient_heist::set_yeast o2 <YEAST>    --assign o3 \
  --move-call $PKG4::ingredient_heist::set_salt  o3 <SALT>     --assign o4 \
  --move-call $PKG4::ingredient_heist::get_flag  o4 \
  --gas-budget 100000000
```

If the CLI complains about the integer type, suffix the amounts with `u16`
(e.g. `1337u16`). When it lands, `iota client objects` shows your `Flag`. 🎉
