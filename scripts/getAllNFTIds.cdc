
import AFLNFT from 0x01cf0e2f2f715450

pub fun main() : [UInt64]{
    let account1 = getAccount(0x179b6b1cb6755e31)
    let acct1Capability =  account1.getCapability(AFLNFT.CollectionPublicPath)
                            .borrow<&{AFLNFT.AFLNFTCollectionPublic}>()
                            ??panic("could not borrow receiver reference ")
    return acct1Capability.getIDs()
}
