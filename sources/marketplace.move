module marketplace::marketplace;

use sui::bag::{Self, Bag};
use sui::table::{Self, Table};
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

public struct AdminCap has key{
    id: UID,
}

const ENotEnoughValue: u64 = 0;
const ENotOwner: u64 = 1;
const EZeroValue: u64 = 2;

fun init(ctx: &mut TxContext) {
    sui::transfer::transfer(AdminCap{id: object::new(ctx)}, ctx.sender());
}

public fun create_marketplace<COIN>(_: &AdminCap, ctx: &mut TxContext) {
    let id = object::new(ctx);
    let items = bag::new(ctx);
    let payments = table::new<address, Coin<COIN>>(ctx); 

    let marketplace = Marketplace<COIN>{id: id, items: items, payments: payments};
    sui::transfer::share_object(marketplace);
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

fun delist<T: key + store, COIN>(
    marketplace: &mut Marketplace<COIN>,
    item_id: ID,
    ctx: &TxContext
): T{
    let Listing{mut id, owner, ..} = bag::remove(&mut marketplace.items, item_id);

    assert!(ctx.sender() == owner, ENotOwner);
    
    let listing_item = dof::remove(&mut id, true);
    id.delete();
    listing_item

}

public fun delist_and_take<T: key + store, COIN>(
    marketplace: &mut Marketplace<COIN>, 
    item_id: ID, 
    ctx: &mut TxContext
) {
    let listed_item = delist<T, COIN>(marketplace, item_id, ctx);
    sui::transfer::public_transfer(listed_item, ctx.sender());
}

fun buy<T: key + store, COIN>(
    marketplace: &mut Marketplace<COIN>, 
    item_id: ID, 
    paid_coin: Coin<COIN>
): T {
    let Listing{mut id, owner, ask} = marketplace.items.remove(item_id);

    assert!(paid_coin.value() == ask, ENotEnoughValue);

    if(marketplace.payments.contains(owner)) {
        marketplace.payments.borrow_mut(owner).join(paid_coin);
    } else {
        marketplace.payments.add(owner, paid_coin);
    };

    let listed_item = dof::remove(&mut id, true);
    id.delete();
    listed_item
}

public fun buy_item<T: key + store, COIN>(
    marketplace: &mut Marketplace<COIN>, 
    item_id: ID, 
    paid_coin: Coin<COIN>,
    ctx: &mut TxContext
) {
    sui::transfer::public_transfer(
        buy<T, COIN>(
            marketplace, 
            item_id, 
            paid_coin
        ),
        ctx.sender()
    );
}

fun withdraw_money<COIN>(marketplace: &mut Marketplace<COIN>, ctx: &TxContext): Coin<COIN> {
    let total_value = marketplace.payments.borrow(ctx.sender()).value();
    assert!(total_value > 0, EZeroValue);

    marketplace.payments.remove(ctx.sender())
}

#[allow(lint(self_transfer))]
public fun withdraw<COIN>(marketplace: &mut Marketplace<COIN>, ctx: &mut TxContext) {
    sui::transfer::public_transfer(
        withdraw_money<COIN>(marketplace, ctx),
        ctx.sender()
    );
    
}