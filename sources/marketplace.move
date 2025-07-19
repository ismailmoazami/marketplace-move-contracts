module marketplace::marketplace;

use sui::bag::{Bag};
use sui::table::Table;
use sui::coin::Coin;
use sui::dynamic_object_field as dof;

public struct Marketplace<phantom COIN> has key {
    id: UID,
    items: Bag, 
    payments: Table<address, Coin<COIN>>
}

public struct Listing has key, store{
    id: UID,
    ask: u64, 
    owner: address
}

public fun list<T: key + store, COIN>(
    marketplace: &mut Marketplace<COIN>, 
    item: T, 
    ask: u64, 
    ctx: &mut TxContext
) {
    let item_id = object::id(&item);
    let mut new_listing = Listing{
        id: object::new(ctx),
        ask: ask, 
        owner: ctx.sender()
    };

    dof::add(&mut new_listing.id, true, item);
    marketplace.items.add(item_id, new_listing);

}