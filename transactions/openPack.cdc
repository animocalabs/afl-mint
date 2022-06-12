
import AFLNFT from 0x4ea480b0fc738e55
import AFLPack from 0x4ea480b0fc738e55
transaction(accountAddress:Address, nftId:UInt64, receiptAddress:Address){
    prepare(acct: AuthAccount) {
        let account = getAccount(accountAddress)
        let adminRef = account
                .getCapability<&{AFLPack.PackPublic}>(AFLPack.PackPublicPath)
                .borrow()
                ?? panic("Could not borrow admin reference")
            
        let collectionRef =  acct.borrow<&AFLNFT.Collection>(from: AFLNFT.CollectionStoragePath)
        ??panic("could not borrow a reference to the the stored nft Collection")

        adminRef.openPack(packNFT :<- collectionRef.withdraw(withdrawID: nftId), receiptAddress: receiptAddress) 
    }


}