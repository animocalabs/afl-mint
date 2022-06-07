import FlowToken from 0x0ae53cb6e3f42a79
import FungibleToken from 0xee82856bf20e2aa6

pub fun main(account:Address):Bool{
    let account = getAccount(account)
    let cap = account.getCapability(/public/flowTokenReceiver)
            .borrow<&FlowToken.Vault{FungibleToken.Receiver}>()
    if cap == nil {
        return false
    }
    return true
}