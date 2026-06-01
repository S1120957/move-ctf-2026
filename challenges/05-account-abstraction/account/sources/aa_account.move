// Copyright (c) 2025 IOTA Stiftung
// SPDX-License-Identifier: Apache-2.0

/// Challenge 5 — Account Abstraction — STAGE A (build & use)
///
/// On IOTA, an "abstract account" replaces fixed signature checking with your own
/// Move logic. You define:
///   * an account object (`AaAccount`), and
///   * an `#[authenticator]` function that the protocol runs *before* a transaction
///     whose sender is the account — it aborts to reject, or returns to accept.
///
/// The flag here can ONLY be obtained by getting a transaction to execute *as the
/// account*: `get_flag` insists that the caller's address equals the account's own
/// address. And a transaction can only run as the account if the account's
/// authenticator accepts it. So to win you must:
///   1. finish the `authenticate` function below (one line — see the TODO),
///   2. publish this package,
///   3. create your account,
///   4. sign and submit a `get_flag` transaction *through* the account.
///
/// The README walks you through steps 2–4 with exact CLI commands.
module aa_account::aa_account;

use iota::account;
use iota::authenticator_function::AuthenticatorFunctionRefV1;
use iota::event;
use public_key_authentication::public_key_authentication as pk;

// === Errors ===

#[error(code = 0)]
const ENotTheAccount: vector<u8> = b"get_flag must be called BY the abstract account itself.";
#[error(code = 1)]
const ENotImplemented: vector<u8> = b"Finish the authenticate function - that's your job!";

// === Structs ===

/// The abstract account. It stores its owner public key as a dynamic field (added
/// in `create`). `key` only — it becomes a shared object via `create_account_v1`.
public struct AaAccount has key {
    id: UID,
}

public struct Flag has key, store {
    id: UID,
    student: address,
}

public struct FlagCaptured has copy, drop {
    flag_id: ID,
    student: address,
}

// === Account lifecycle ===

/// Create the abstract account as a shared object, owned by `public_key`, with
/// `authenticator` as its authenticate function. Must live in this module because
/// `create_account_v1` is verifier-restricted to the module that declares the
/// account type.
public fun create(
    public_key: vector<u8>,
    authenticator: AuthenticatorFunctionRefV1<AaAccount>,
    ctx: &mut TxContext,
) {
    let mut account = AaAccount { id: object::new(ctx) };
    pk::attach_public_key(&mut account.id, public_key);
    account::create_account_v1(account, authenticator);
}

// === Authenticator ===

/// Runs before any transaction sent *as* this account. Accept by returning, reject
/// by aborting.
#[authenticator]
public fun authenticate(
    account: &AaAccount,
    signature: vector<u8>,
    auth_ctx: &AuthContext,
    ctx: &TxContext,
) {
    // TODO(challenge 5, stage A): verify that `signature` is a valid Ed25519
    // signature by the account's owner over the transaction digest (it aborts
    // if the signature is invalid):
    //
    // Replace the abort below with that change.
    abort ENotImplemented
}

// === The flag ===

/// Capture the flag — but only when the transaction is executing AS this account.
public entry fun get_flag(account: &AaAccount, ctx: &mut TxContext) {
    assert!(account.id.to_address() == ctx.sender(), ENotTheAccount);

    let student = ctx.sender();
    let flag = Flag { id: object::new(ctx), student };
    event::emit(FlagCaptured { flag_id: object::id(&flag), student });
    transfer::public_transfer(flag, student);
}

// === Views ===

public fun borrow_uid(self: &AaAccount): &UID { &self.id }

public fun account_address(self: &AaAccount): address { self.id.to_address() }

// === Test-only ===

/// Shares a bare `AaAccount` (no authenticator wiring) so tests can exercise
/// `get_flag`'s address guard without the full on-chain auth machinery.
#[test_only]
public fun share_for_testing(public_key: vector<u8>, ctx: &mut TxContext): address {
    let mut account = AaAccount { id: object::new(ctx) };
    pk::attach_public_key(&mut account.id, public_key);
    let addr = account.id.to_address();
    transfer::share_object(account);
    addr
}
