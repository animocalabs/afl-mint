
import AFLNFT from 0xa33d4223b3818e3f

pub fun main(account:Address) : [UInt64]{
    let account1 = getAccount(account)
    let acct1Capability =  account1.getCapability(AFLNFT.CollectionPublicPath)
                            .borrow<&{AFLNFT.AFLNFTCollectionPublic}>()
                            ??panic("could not borrow receiver reference ")
    return acct1Capability.getIDs()
}
