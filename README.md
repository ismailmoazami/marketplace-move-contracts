# Sui Move Marketplace Contract 🏪

A decentralized marketplace smart contract built on Sui blockchain using Move language. Buy and sell any asset with any coin type - completely trustless and secure.

## Features ✨

- **Generic Design**: Works with any asset type and any coin type
- **Trustless Trading**: No intermediaries needed
- **Secure Escrow**: Payments held safely until withdrawal
- **Admin Controls**: Only admins can create new marketplaces
- **Flexible Listing**: List any item with custom pricing

## How It Works 🔄

1. **Admin creates marketplace** for specific coin type (SUI, USDC, etc.)
2. **Sellers list items** with their asking price
3. **Buyers purchase items** by paying the exact amount
4. **Sellers withdraw earnings** anytime they want
5. **Sellers can delist** unsold items anytime

## Key Functions 🔧

### For Admins
- `create_marketplace<COIN>()` - Create new marketplace

### For Sellers
- `list<T, COIN>()` - List an item for sale
- `delist_and_take<T, COIN>()` - Remove listing and get item back
- `withdraw<COIN>()` - Withdraw earned coins

### For Buyers  
- `buy_item<T, COIN>()` - Purchase a listed item

## Example Usage 💡

```move
// Admin creates a SUI marketplace
create_marketplace<SUI>(admin_cap, ctx);

// Alice lists her NFT for 100 SUI
list<MyNFT, SUI>(marketplace, nft, 100_000_000_000, ctx);

// Bob buys the NFT
buy_item<MyNFT, SUI>(marketplace, item_id, sui_coin, ctx);

// Alice withdraws her 100 SUI
withdraw<SUI>(marketplace, ctx);
```

## Security Features 🛡️

- **Owner verification**: Only item owners can delist
- **Exact payment**: Buyers must pay the exact asking price
- **Type safety**: Move's type system prevents common errors
- **No double spending**: Built-in protection against payment issues

## Built With 🏗️

- **Sui Move** - Smart contract language
- **Dynamic Object Fields** - For flexible item storage
- **Bag & Table** - Efficient data structures
- **Generic Types** - Maximum flexibility

---

*Built with ❤️ on Sui blockchain*