
import AFLNFT from 0xa33d4223b3818e3f
import AFLPack from 0xa33d4223b3818e3f
transaction(accountAddress:Address, nftId:UInt64, receiptAddress:Address){
    prepare(acct: AuthAccount) {
        let account = getAccount(accountAddress)
        let adminRef = account
                .getCapability<&{AFLPack.PackPublic}>(AFLPack.PackPublicPath)
                .borrow()
                ?? panic("Could not borrow admin reference")
            
        let collectionRef =  acct.borrow<&AFLNFT.Collection>(from: AFLNFT.CollectionStoragePath)
        ??panic("could not borrow a reference to the the stored nft Collection")

        adminRef.openPack(packNFT :<- (collectionRef.withdraw(withdrawID: nftId) as! @AFLNFT.NFT), receiptAddress: receiptAddress) 
    }


}