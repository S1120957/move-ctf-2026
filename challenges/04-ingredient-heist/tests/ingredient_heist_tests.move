// Copyright (c) 2025 IOTA Stiftung
// SPDX-License-Identifier: Apache-2.0

// A behavior test, not a solution. It shows how to chain the seasoning functions
// (here with the WRONG amounts) and confirms the chef rejects an incorrect recipe.
// Finding the right amounts — by decoding `EXPECTED_RECIPE` — is your job.
#[test_only]
module ingredient_heist::ingredient_heist_tests;

use iota::test_scenario as ts;
use ingredient_heist::ingredient_heist;

#[test]
#[expected_failure(abort_code = ingredient_heist::EWrongRecipe)]
fun wrong_recipe_is_rejected() {
    let user = @0xC;
    let mut scenario = ts::begin(user);

    // Build an order and thread it through the setters (method-call syntax mirrors
    // how a PTB threads a result from one command to the next).
    let order = ingredient_heist::open_order()
        .set_flour(1)
        .set_water(2)
        .set_yeast(3)
        .set_salt(4);

    ingredient_heist::get_flag(order, scenario.ctx()); // wrong recipe -> aborts

    scenario.end();
}
