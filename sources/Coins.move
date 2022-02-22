module Sender::Coins {
    use Std::Signer;

    /// This is Move struct object that corresponds to some number of `Coin`.
    /// In Move, all struct objects can have "abilities" from a hardcoded set of {copy, key, store, drop}.
    /// This one has only `store` ability, which means it can be a part of root level resource in Move Storage.
    struct Coins has store { val: u64 }

    /// This is Move resource object which is marked by `key` ability. It can be added to the Move Storage directly.
    struct Balance has key {
        /// It contains a number of Coins inside.
        coins: Coins
    }

    /// In Move you cannot directly create an instance of `Coin` from script,
    /// instead you need to use available constructor methods. In general case, those methods could have some permission
    /// restrictions, i.e. `mint(acc, val: u64)` method would require `&signer` of coin creator as the first argument
    /// which is only available in transactions signed by that account.
    public fun mint(val: u64): Coins {
        let new_coin = Coins{ val };
        new_coin
    }

    /// If struct object does not have `drop` ability, it cannot be destroyed at the end of the script scope,
    /// and needs explicit desctructuring method.
    public fun burn(coin: Coins) {
        let Coins{ val: _ } = coin;
    }

    public fun deposit(acc: &signer, coin: Coins) acquires Balance {
        let acc_addr = Signer::address_of(acc);
        if (!exists<Balance>(acc_addr)) {
            let zero_coins = Coins{ val: 0 };
            move_to(acc, Balance{ coins: zero_coins });
        };

        let Coins { val } = coin;
        let balance = borrow_global_mut<Balance>(acc_addr);
        balance.coins.val = balance.coins.val + val;
    }

    public fun withdraw(acc: &signer, val: u64): Coins acquires Balance {
        let acc_addr = Signer::address_of(acc);
        if (!exists<Balance>(acc_addr)) {
            let zero_coins = Coins{ val: 0 };
            move_to(acc, Balance{ coins: zero_coins });
        };

        let balance = borrow_global_mut<Balance>(acc_addr);
        balance.coins.val = balance.coins.val - val;
        Coins{ val }
    }

    public fun balance(acc_addr: address): u64 acquires Balance {
        borrow_global_mut<Balance>(acc_addr).coins.val
    }
}