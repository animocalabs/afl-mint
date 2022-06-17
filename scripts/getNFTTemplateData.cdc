
import AFLNFT from 0x01cf0e2f2f715450

pub fun main(account:Address) : {UInt64:AnyStruct}{
    let account1 = getAccount(account)
    let acct1Capability =  account1.getCapability(AFLNFT.CollectionPublicPath)
                            .borrow<&{AFLNFT.AFLNFTCollectionPublic}>()
                            ??panic("could not borrow receiver reference ")
    let nftIds =  acct1Capability.getIDs()
    var dict : {UInt64: AnyStruct} = {}
    for nftId in nftIds {
        var nftData = AFLNFT.getNFTData(nftId: nftId)
        var templateDataById =  AFLNFT.getTemplateById(templateId: nftData.templateId)
        var nftMetaData : {String:AnyStruct} = {}
        
        nftMetaData["mintNumber"] =nftData.mintNumber;
        nftMetaData["templateId"] = nftData.templateId
        nftMetaData["templateData"] = templateDataById;
        dict.insert(key: nftId,nftMetaData)
    }
    return dict
}
