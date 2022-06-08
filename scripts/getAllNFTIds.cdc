
import AFLNFT from 0x01cf0e2f2f715450

pub fun main(account:Address) : [UInt64]{
    let account1 = getAccount(account)
    let acct1Capability =  account1.getCapability(AFLNFT.CollectionPublicPath)
                            .borrow<&{AFLNFT.AFLNFTCollectionPublic}>()
                            ??panic("could not borrow receiver reference ")
    return acct1Capability.getIDs()
}
