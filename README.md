# Move CTF Workshop — Learn Move on IOTA in 5 Challenges

A hands-on, capture-the-flag style workshop that takes you from *"what is a Move
package?"* to **writing and breaking an account-abstraction authenticator** — in
about three hours. Inspired by the official
[IOTA Move CTF](https://docs.iota.org/developer/iota-move-ctf/introduction).

Each challenge ends the same way the official CTF does: you make a `get_flag`
function succeed and end up owning a **`Flag`** object. The first two challenges
ask you to *write* Move; the last three ask you to *read, compose, and exploit*
contracts that are already deployed — just like the real CTF.

## The challenges

| # | Challenge | Difficulty | Mode | What you learn |
|---|-----------|------------|------|----------------|
| 1 | [Checkpoint](challenges/01-checkpoint/) | ⭐ | write | packages, objects & abilities, `TxContext`, transfer, events, the build/test loop |
| 2 | [Vault Guard](challenges/02-vault-guard/) | ⭐⭐ | write | shared objects, `init`, `&mut` references, `assert!` + error codes, attempt limits |
| 3 | [Mint Master](challenges/03-mint-master/) | ⭐⭐⭐ | interact | the Coin standard, `TreasuryCap`, `Balance`, split/join, capability pattern |
| 4 | [Ingredient Heist](challenges/04-ingredient-heist/) | ⭐⭐⭐⭐ | interact | Programmable Transaction Blocks, the hot-potato pattern, BCS serialization |
| 5 | [Account Abstraction](challenges/05-account-abstraction/) | ⭐⭐⭐⭐⭐ | build + exploit | custom `#[authenticator]`s, `AuthContext`, driving a tx through an abstract account, and an exploit bonus |

Suggested pacing: setup ~20 min · C1 ~15 · C2 ~25 · C3 ~30 · C4 ~35 · C5 ~45 ·
wrap-up ~10. Challenge 5's exploit stage is a stretch / take-home.

## How a flag works

Every challenge package defines:

```move
public struct Flag has key, store { id: UID, student: address }
public struct FlagCaptured has copy, drop { flag_id: ID, student: address }
```

`get_flag(...)` validates the challenge condition, then mints a `Flag` to you and
emits `FlagCaptured`. Two ways to prove you captured it:

- **Unit-test challenges (1–2):** the provided test goes green (`iota move test`).
- **On-chain challenges (3–5):** you own a new `Flag` object and a `FlagCaptured`
  event was emitted. Confirm with [`scripts/verify-flag.sh`](scripts/verify-flag.sh)
  or `iota client objects`, and submit the `Flag` object id to your instructor's
  scoreboard.

## The rules (for the interact challenges)

Challenges 3–5 ship the contract **already written**. As in the real CTF, you do
**not** modify the deployed module — you win by *calling* its functions and
*composing transactions* (PTBs) cleverly enough to satisfy `get_flag`. (Challenge 5
also asks you to author one authenticator function of your own; its README spells
out exactly which file is yours to edit.)

## Getting started

1. Read [`SETUP.md`](SETUP.md): install the IOTA CLI, create a key, and point it at
   devnet.
2. `cd challenges/01-checkpoint` and follow its README. Challenges 1–2 are pure Move —
   nothing needs to be deployed.
3. **Before challenges 3–5**, deploy their on-chain packages once. From the repo root:

   ```bash
   ./scripts/deploy-all.sh    # publishes Mint Master (3), Ingredient Heist (4),
                              # and the Challenge 5 Stage B vulnerable account
   source .workshop.env       # load PKG3, TREASURY3, PKG4, VPKG, VACC into your shell
   ```

   (Challenge 5 **Stage A** you publish yourself — its README walks you through it.)
4. Work through the challenges in order — each builds on the last.

You don't need this repository's git history or the IOTA monorepo: every package
pulls the framework from a pinned git revision, so `iota move build` / `iota move
test` work in a fresh clone.

## Repository layout

```
move-ctf-workshop/
├── README.md                  # you are here
├── SETUP.md                   # toolchain + network setup
├── challenges/                # the 5 challenge packages (your working copies)
│   ├── 01-checkpoint/  …  05-account-abstraction/
├── lib/                       # shared, vendored helper packages (no monorepo dep)
│   └── public_key_authentication/
└── scripts/
    ├── deploy-all.sh          # deploy challenges 3, 4 & 5B — run before those
    └── verify-flag.sh         # confirm a flag was captured
```

## License

Apache-2.0. See [`LICENSE`](LICENSE).
