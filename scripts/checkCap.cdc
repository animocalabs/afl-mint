import FlowToken from 0x7e60df042a9c0868
import FungibleToken from 0x9a0766d93b6608b7
import FiatToken from 0xa983fecbed621163
import AFLNFT from 0xa33d4223b3818e3f
pub fun main(account:Address): Bool{
    let account1 = getAccount(account)
    let cap = account1.getCapability<&{AFLNFT.AFLNFTCollectionPublic}>(AFLNFT.CollectionPublicPath)
    return cap.check()
}