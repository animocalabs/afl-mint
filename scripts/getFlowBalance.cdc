import FlowToken from 0x7e60df042a9c0868
import FungibleToken from 0x9a0766d93b6608b7
import FiatToken from 0xa983fecbed621163
pub fun main(account:Address): UFix64 {
    let account = getAccount(account)
    let vaultCap = account.getCapability(FiatToken.VaultBalancePubPath)
                            .borrow<&FiatToken.Vault{FungibleToken.Balance}>()
                            ??panic("could not borrow receiver reference ")

    return vaultCap.balance

}