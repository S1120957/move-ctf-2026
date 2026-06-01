# Challenge 2 — Vault Guard

> **Difficulty:** ⭐⭐ · **Mode:** write Move · **Goal:** crack the shared lock

## Story

The flag is locked in a vault on the town square — a *shared* object that anyone
can walk up to and turn. The dial starts at `0`. Spin it until it reads exactly
**1337**, then claim your prize. Careful: the vault jams after 100 turns.

## What you'll learn

- **Shared objects:** `transfer::share_object` and the `init` function that runs at
  publish time. State lives on-chain and persists *between* transactions.
- **Mutable references (`&mut`):** how to read and write shared state safely.
- **`assert!` + custom error codes:** enforcing rules with `#[error]` constants.
- A first taste of an **attempt limit** — a pattern every on-chain game uses.

## Your task

Open [`sources/vault_guard.move`](sources/vault_guard.move) and implement two
functions:

- `turn(vault, clicks)` — abort with `ETooManyAttempts` if the attempt limit is
  reached; otherwise record the attempt and add `clicks` to the dial.
- `get_flag(vault, ctx)` — abort with `EWrongCombination` unless the dial equals
  `TARGET`, then award the flag.

Solved when both tests pass:

```bash
iota move test
# [ PASS    ] vault_guard::vault_guard_tests::cracks_the_vault
# [ PASS    ] vault_guard::vault_guard_tests::wrong_combination_aborts
```

## Hints

<details>
<summary>Hint 1 — turning the dial</summary>

You mutate shared state through the `&mut Vault`:
`vault.attempts = vault.attempts + 1;` and `vault.dial = vault.dial + clicks;`.
Guard it first with `assert!(vault.attempts < MAX_ATTEMPTS, ETooManyAttempts);`.
</details>

<details>
<summary>Hint 2 — opening the vault</summary>

`assert!(vault.dial == TARGET, EWrongCombination);` then call the provided
`award_flag(ctx)`.
</details>

<details>
<summary>Hint 3 — why two transactions?</summary>

The test turns the dial in one transaction and opens the vault in another. Because
the `Vault` is *shared*, its `dial` value survives between them — that's the whole
point of a shared object.
</details>

## Going on-chain (optional)

```bash
iota client publish --gas-budget 100000000          # note packageId AND the shared Vault object id
# turn the dial (shared object passed by id), then open it:
iota client call --package <PKG> --module vault_guard --function turn     --args <VAULT_ID> 1337 --gas-budget 100000000
iota client call --package <PKG> --module vault_guard --function get_flag --args <VAULT_ID>      --gas-budget 100000000
iota client objects   # your Flag is the proof
```
