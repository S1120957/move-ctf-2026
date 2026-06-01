// Copyright (c) 2025 IOTA Stiftung
// SPDX-License-Identifier: Apache-2.0

/// Challenge 5 — Account Abstraction — STAGE B (exploit, bonus)
///
/// This account is already deployed by the organisers, guarding its own flag. It is
/// owned by a public key whose private key you do NOT have. Its authenticator is
/// meant to require a valid Ed25519 signature from the owner before any transaction
/// may run as the account.
///
/// And yet... a careful reading of `authenticate` shows the owner's signature is not
/// actually enforced. Find the flaw, then submit a `get_flag` transaction as this
/// account — with a signature you simply made up — and walk away with the flag.
///
/// You may NOT modify this contract. The exploit is entirely in how you call it.
module vulnerable_account::vulnerable_account;

use iota::account;
use iota::authenticator_function::AuthenticatorFunctionRefV1;
use iota::ed25519;
use iota::event;
use public_key_authentication::public_key_authentication as pk;

// === Errors ===

#[error(code = 0)]
const ENotTheAccount: vector<u8> = b"get_flag must be called BY the abstract account itself.";

// === Structs ===

public struct VulnAccount has key {
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

public fun create(
    public_key: vector<u8>,
    authenticator: AuthenticatorFunctionRefV1<VulnAccount>,
    ctx: &mut TxContext,
) {
    let mut account = VulnAccount { id: object::new(ctx) };
    pk::attach_public_key(&mut account.id, public_key);
    account::create_account_v1(account, authenticator);
}

// === Authenticator ===

#[authenticator]
public fun authenticate(
    account: &VulnAccount,
    signature: vector<u8>,
    _auth_ctx: &AuthContext,
    ctx: &TxContext,
) {
    // Authenticate the owner's Ed25519 signature over the transaction digest.
    let public_key = pk::borrow_public_key(account.borrow_uid());
    let _verified = ed25519::ed25519_verify(&signature, public_key, ctx.digest());
}

// === The flag ===

public entry fun get_flag(account: &VulnAccount, ctx: &mut TxContext) {
    assert!(account.id.to_address() == ctx.sender(), ENotTheAccount);

    let student = ctx.sender();
    let flag = Flag { id: object::new(ctx), student };
    event::emit(FlagCaptured { flag_id: object::id(&flag), student });
    transfer::public_transfer(flag, student);
}

// === Views ===

public fun borrow_uid(self: &VulnAccount): &UID { &self.id }

public fun account_address(self: &VulnAccount): address { self.id.to_address() }
