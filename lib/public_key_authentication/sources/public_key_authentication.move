// Copyright (c) 2025 IOTA Stiftung
// SPDX-License-Identifier: Apache-2.0

/// Helper module for public-key based authentication of abstract accounts.
///
/// It lets an account store an Ed25519 public key as a dynamic field; any
/// authenticator can then verify a signature against that key. This is a trimmed,
/// vendored copy of the `public_key_authentication` example from the IOTA monorepo,
/// kept inside the workshop kit so it has no dependency on the monorepo tree.
///
/// Only the Ed25519 path needed by Challenge 5 is included here.
module public_key_authentication::public_key_authentication;

use iota::dynamic_field as df;
use iota::ed25519;

// === Errors ===

#[error(code = 0)]
const EPublicKeyAlreadyAttached: vector<u8> = b"Public key already attached.";
#[error(code = 1)]
const EPublicKeyMissing: vector<u8> = b"Public key missing.";
#[error(code = 2)]
const EEd25519VerificationFailed: vector<u8> = b"Ed25519 authenticator verification failed.";

// === Structs ===

/// A dynamic field name for the account owner public key.
public struct PublicKeyFieldName has copy, drop, store {}

// === Public Functions ===

/// Attach `public_key` to the account identified by `account_id`.
public fun attach_public_key(account_id: &mut UID, public_key: vector<u8>) {
    assert!(!has_public_key(account_id), EPublicKeyAlreadyAttached);
    df::add(account_id, PublicKeyFieldName {}, public_key)
}

/// Replace the public key attached to the account, returning the previous one.
public fun rotate_public_key(account_id: &mut UID, public_key: vector<u8>): vector<u8> {
    assert!(has_public_key(account_id), EPublicKeyMissing);
    let prev = df::remove(account_id, PublicKeyFieldName {});
    df::add(account_id, PublicKeyFieldName {}, public_key);
    prev
}

/// Ed25519 signature authenticator helper.
///
/// Verifies `signature` over the current transaction digest (`ctx.digest()`)
/// against the account's attached public key. Aborts if verification fails.
public fun authenticate_ed25519(account_id: &UID, signature: vector<u8>, ctx: &TxContext) {
    assert!(has_public_key(account_id), EPublicKeyMissing);
    assert!(
        ed25519::ed25519_verify(&signature, borrow_public_key(account_id), ctx.digest()),
        EEd25519VerificationFailed,
    );
}

// === View Functions ===

/// Returns `true` if a public key is attached to the account.
public fun has_public_key(account_id: &UID): bool {
    df::exists_(account_id, PublicKeyFieldName {})
}

/// Borrow the account's attached public key.
public fun borrow_public_key(account_id: &UID): &vector<u8> {
    df::borrow(account_id, PublicKeyFieldName {})
}
