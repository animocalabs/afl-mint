
import AFLNFT from 0x01cf0e2f2f715450
import AFLPack from 0x01cf0e2f2f715450
transaction(accountAddress:Address){
    prepare(acct: AuthAccount) {
        let account = getAccount(accountAddress)
        let adminRef = account
                .getCapability<&{AFLPack.PackPublic}>(AFLPack.PackPublicPath)
                .borrow()
                ?? panic("Could not borrow admin reference")
            
        let collectionRef =  acct.borrow<&AFLNFT.Collection>(from: AFLNFT.CollectionStoragePath)
        ??panic("could not borrow a reference to the the stored nft Collection")

        adminRef.openPack(packNFT :<- (collectionRef.withdraw(withdrawID: 1) as! @AFLNFT.NFT), receiptAddress: 0x179b6b1cb6755e31) 
    }


}