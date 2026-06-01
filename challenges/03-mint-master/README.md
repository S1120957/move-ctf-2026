# Challenge 3 — Mint Master

> **Difficulty:** ⭐⭐⭐ · **Mode:** interact (don't modify the contract) · **Goal:** pay exactly 5

## Story

The Mint Master runs a vending machine that dispenses flags — but it's fussy. It
only accepts a single `MINT` coin worth **exactly 5**. The catch: the mint button
always gives you coins worth **2**. You'll have to mint a few, fuse them together,
and slice off the precise amount.

## What you'll learn

- The **Coin standard**: a custom currency created with a **one-time witness** and a
  shared **`TreasuryCap`**.
- **Resource semantics**: coins can't be copied or dropped — they must be split,
  joined, spent, or transferred.
- The everyday coin operations: minting, **`join`** (merge), and **`split`**.

## The rules

The contract in [`sources/mint_master.move`](sources/mint_master.move) is already
deployed. **Read it, but do not change it.** You win by calling its functions and
manipulating coins from the command line.

Functions available to you:

| Function | What it does |
|----------|--------------|
| `mint(treasury)` | sends you one `MINT` coin worth 2 |
| `burn(treasury, coin)` | destroys a coin |
| `get_flag(coin)` | gives you the flag **iff** `coin` is worth exactly 5 |

## How to solve

This challenge is already deployed for you. Run `scripts/deploy-all.sh` and
`source .workshop.env` (see the [top-level README](../../README.md#getting-started)) —
that sets `$PKG3` (package id) and `$TREASURY3` (shared treasury id). Then:

```bash
# 1. Mint three coins of 2 (total 6):
iota client call --package $PKG3 --module mint_master --function mint --args $TREASURY3 --gas-budget 100000000
iota client call --package $PKG3 --module mint_master --function mint --args $TREASURY3 --gas-budget 100000000
iota client call --package $PKG3 --module mint_master --function mint --args $TREASURY3 --gas-budget 100000000

# 2. Find your three MINT coin object ids:
iota client objects        # look for type ...::mint_master::MINT_MASTER

# 3. Fuse them into one coin worth 6:
iota client merge-coin --primary-coin $C1 --coin-to-merge $C2 --gas-budget 100000000
iota client merge-coin --primary-coin $C1 --coin-to-merge $C3 --gas-budget 100000000

# 4. Slice off exactly 5 (leaves 1 behind in $C1):
iota client split-coin --coin-id $C1 --amounts 5 --gas-budget 100000000   # note the NEW coin id -> $FIVE

# 5. Pay it to the machine:
iota client call --package $PKG3 --module mint_master --function get_flag --args $FIVE --gas-budget 100000000
```

`iota client objects` will now show your `Flag`. 🎉
