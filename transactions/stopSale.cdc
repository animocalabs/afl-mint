import AFLNFT from 0x01cf0e2f2f715450
import FungibleToken from 0xee82856bf20e2aa6
import AFLMarketplace from 0x01cf0e2f2f715450
import FlowToken from 0x0ae53cb6e3f42a79


// This transaction is for a user to stop a moment sale in their account
// by withdrawing that moment from their sale collection and depositing
// it into their normal moment collection
// Parameters
//
// tokenID: the ID of the moment whose sale is to be delisted

transaction(tokenID:UInt64){
    let collectionRef: &AFLNFT.Collection
    let AFLMarketplaceSaleCollectionRef: &AFLMarketplace.SaleCollection

    prepare(account:AuthAccount){

        let marketplaceCap = account.getCapability<&{AFLMarketplace.SalePublic}>(/public/AFLSaleCollection)
        if !marketplaceCap.check(){
            let wallet =  account.getCapability<&FlowToken.Vault{FungibleToken.Receiver}>(/public/flowTokenReceiver)
            let sale <- AFLMarketplace.createSaleCollection(ownerVault: wallet)

            account.save<@AFLMarketplace.SaleCollection>(<-sale    , to: /storage/AFLSaleCollection)

            account.link<&{AFLMarketplace.SalePublic}>(/public/AFLSaleCollection, target: /storage/AFLSaleCollection)
            
        }
        
        self.collectionRef = account.borrow<&AFLNFT.Collection>(from: /storage/AFLNFTCollection)!
        self.AFLMarketplaceSaleCollectionRef = account.borrow<&AFLMarketplace.SaleCollection>(from: /storage/AFLSaleCollection)!
        }
    execute{
        
        let token <- self.AFLMarketplaceSaleCollectionRef.withdraw(tokenID: tokenID)
        self.collectionRef.deposit(token: <- token)
    }
}