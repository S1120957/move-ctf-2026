# Challenge 1 — Checkpoint

> **Difficulty:** ⭐ (warm-up) · **Mode:** write Move · **Goal:** capture your first `Flag`

## Story

Before the real heists begin, every agent has to pass the checkpoint. There is no
lock to pick here — you just need to prove you can build, test, and run a Move
module. Mint yourself a `Flag` and you're in.

## What you'll learn

- The anatomy of a Move package: `Move.toml`, `sources/`, `tests/`.
- Defining an object: a `struct` with the `key` (and `store`) ability and a `UID`.
- Reading the caller from the `TxContext` (`ctx.sender()`).
- Creating an object (`object::new`), emitting an `event`, and transferring an
  object to an address (`transfer::public_transfer`).
- The build / test loop: `iota move build` and `iota move test`.

## Your task

Open [`sources/checkpoint.move`](sources/checkpoint.move) and implement the body of
`get_flag`. It must:

1. create a `Flag` owned by the caller,
2. emit a `FlagCaptured` event, and
3. transfer the `Flag` to the caller.

The challenge is solved when the test in
[`tests/checkpoint_tests.move`](tests/checkpoint_tests.move) passes.

## How to solve

```bash
# from this directory
iota move build      # compiles; you'll see warnings until you implement get_flag
iota move test       # FAILS now, PASSES once get_flag is implemented
```

When you see:

```
[ PASS    ] checkpoint::checkpoint_tests::student_captures_flag
Test result: OK. Total tests: 1; passed: 1; failed: 0
```

…you've captured the flag. 🎉

## Hints

<details>
<summary>Hint 1 — creating the object</summary>

`object::new(ctx)` returns a fresh `UID`. Build the struct with it:
`let flag = Flag { id: object::new(ctx), student: _student };`
</details>

<details>
<summary>Hint 2 — the event and the transfer</summary>

`object::id(&flag)` gives the `ID` for the event. `object`, `transfer` and the
struct constructors are always in scope; `event` is already imported at the top of
the module.
</details>

## Going on-chain (optional)

The flag also works for real. Once your test passes, publish to devnet and capture
an on-chain flag object:

```bash
iota client publish --gas-budget 100000000
# note the published packageId, then:
iota client call --package <PACKAGE_ID> --module checkpoint --function get_flag --gas-budget 100000000
iota client objects   # your new Flag object id is your on-chain proof
```

See [`../../SETUP.md`](../../SETUP.md) for installing the CLI and pointing it at devnet.
