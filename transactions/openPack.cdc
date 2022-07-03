
import AFLNFT from 0xf33e541cb9446d81
import AFLPack from 0xf33e541cb9446d81
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