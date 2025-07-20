module marketplace::widget; 

public struct Widget has key, store {
    id: UID,
}

#[allow(lint(self_transfer))]
public fun mint(ctx: &mut TxContext) {
    let widget = Widget{id: object::new(ctx)};
    sui::transfer::transfer(widget, ctx.sender());
}