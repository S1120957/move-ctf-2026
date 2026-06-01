# Challenge 5 — Account Abstraction

> **Difficulty:** ⭐⭐⭐⭐⭐ · **Mode:** build (Stage A) + exploit (Stage B, bonus) · **Goal:** become the account

This is the capstone. On IOTA, an **abstract account** swaps the usual fixed
signature check for *your own Move logic* — an `#[authenticator]` function the
protocol runs before any transaction sent **as** that account. You'll build one and
drive a transaction through it; then, for bonus points, you'll break a flawed one.

> **Prerequisites:** devnet access (see [`../../SETUP.md`](../../SETUP.md)) and
> `jq` + `python3`. Account Abstraction must be enabled on devnet.

---

## Stage A — Build & use your own account (main flag)

The flag in [`account/`](account/) is gated by:

```move
public entry fun get_flag(account: &AaAccount, ctx: &mut TxContext) {
    assert!(account.id.to_address() == ctx.sender(), ENotTheAccount);
    ...
}
```

It only mints the flag if the caller **is** the account. The only way a transaction
runs as the account is if the account's authenticator accepts it. So you must finish
the authenticator, then sign a transaction the way the account demands.

### Step 0 — finish the authenticator (this is the "write" part)

In [`account/sources/aa_account.move`](account/sources/aa_account.move), replace the
`abort ENotImplemented` in `authenticate` with the one line that verifies the
owner's signature:

```move
pk::authenticate_ed25519(&account.id, signature, ctx);
```

`cd account && iota move build` to make sure it compiles.

### Step 1 — set up names and your owner key

Your normal Ed25519 address will own the account.

```bash
cd account
export ACC_MODULE=aa_account ACC_TYPE=AaAccount AUTH_FN=authenticate

export OWNER=$(iota client active-address)
# the raw 32-byte Ed25519 public key, as a Move `vector<u8>` literal:
OWNER_PK_HEX=$(iota keytool export $OWNER --json | jq -r '.key.publicBase64Key' | base64 -d | od -An -tx1 | tr -d ' \n')
export OWNER_PK_BYTES=$(python3 -c "print([int('$OWNER_PK_HEX'[i:i+2],16) for i in range(0,len('$OWNER_PK_HEX'),2)])")
echo "owner pk bytes: $OWNER_PK_BYTES"
```

### Step 2 — publish

```bash
JSON=$(iota client publish --with-unpublished-dependencies --json)
export PKG=$(echo "$JSON" | jq -r '.objectChanges[] | select(.type=="published") | .packageId')
export METADATA_ID=$(echo "$JSON" | jq -r '.objectChanges[] | select(.objectType=="0x2::package_metadata::PackageMetadataV1") | .objectId')
echo "PKG=$PKG  METADATA_ID=$METADATA_ID"
```

### Step 3 — create your account

One PTB: build an authenticator function reference, then call `create`.

```bash
PTB_JSON=$(iota client ptb \
  --move-call 0x2::authenticator_function::create_auth_function_ref_v1 "<$PKG::$ACC_MODULE::$ACC_TYPE>" @$METADATA_ID "\"$ACC_MODULE\"" "\"$AUTH_FN\"" \
  --assign ref \
  --move-call $PKG::$ACC_MODULE::create "vector$OWNER_PK_BYTES" ref \
  --json)
export ACCOUNT=$(echo "$PTB_JSON" | jq -r '.objectChanges[] | select(.objectType | endswith("::aa_account::AaAccount")) | .objectId')
echo "ACCOUNT=$ACCOUNT"
```

### Step 4 — act as the account and grab the flag

Register the account locally, switch to it, and fund it so it can pay its own gas:

```bash
iota client add-account $ACCOUNT
iota client switch --address $ACCOUNT
iota client faucet
```

Now build the `get_flag` transaction **unsigned**, sign its digest with the *owner*
key, strip the IOTA signature down to the raw 64-byte Ed25519 signature, and execute
it with that signature as `--auth-call-args`:

```bash
UNSIGNED=$(iota client ptb \
  --move-call $PKG::$ACC_MODULE::get_flag @$ACCOUNT \
  --serialize-unsigned-transaction)

TX_DIGEST_HEX=$(iota keytool tx-digest "$UNSIGNED" --json | jq -r '.digestHex')

IOTA_SIG_HEX=$(iota keytool sign-raw --address $OWNER --data $TX_DIGEST_HEX --json | jq -r '.iotaSignature' | base64 -d | od -An -tx1 | tr -d ' \n')
# drop the 1-byte scheme flag and 32-byte public key -> 64-byte raw signature
SIG_HEX=$(echo $IOTA_SIG_HEX | cut -c 3-130)

SIGNED=$(iota client ptb \
  --move-call $PKG::$ACC_MODULE::get_flag @$ACCOUNT \
  --auth-call-args 0x$SIG_HEX \
  --serialize-signed-transaction)

iota client execute-combined-signed-tx --signed-tx-bytes "$SIGNED"
```

The `Flag` is now owned by your abstract account:

```bash
iota client objects   # you are switched to the account; the Flag is here
```

> **What just happened:** the protocol saw a transaction whose sender is the account,
> looked up the account's `authenticate` function, and ran it with your
> `--auth-call-args` as `signature`. Your code verified that signature against the
> stored public key over the tx digest, and accepted. Only then did `get_flag` run —
> as the account.

---

## Stage B — Exploit a broken authenticator (bonus flag)

The organisers deployed a second account in [`vulnerable-account/`](vulnerable-account/),
guarding its own flag. It is owned by a public key whose private key you do **not**
have — so Stage A's approach won't work. But read its `authenticate` carefully.

Your goal: capture `vulnerable_account`'s flag without the owner's key. You may not
change the contract — the exploit is in how you call it.

```bash
# the vulnerable package id and account id come from deploy-all.sh:
source .workshop.env    # run from the repo root; sets VPKG and VACC
echo "$VPKG" "$VACC"    # confirm they're set
```
