import FungibleToken from 0x0ae53cb6e3f42a79
import AFLMarketplace from 0x01cf0e2f2f715450
import AFLNFT from 0x01cf0e2f2f715450
import FlowToken from 0x0ae53cb6e3f42a79

// This transaction puts a moment owned by the user up for sale
// Parameters:

// momentID: ID of moment to be put on sale
// price: price of moment
transaction(momentID: UInt64, price: UFix64) {

    // Local variables for the AFLNFT collection and AFLMarketplace sale collection objects
    let collectionRef: &AFLNFT.Collection
    let AFLMarketplaceSaleCollectionRef: &AFLMarketplace.SaleCollection
    
    prepare(acct: AuthAccount) {

        let marketplaceCap = acct.getCapability<&{AFLMarketplace.SalePublic}>(/public/AFLSaleCollection)
        if !marketplaceCap.check(){
            let wallet =  acct.getCapability<&FlowToken.Vault{FungibleToken.Receiver}>(/public/flowTokenReceiver)
            let sale <- AFLMarketplace.createSaleCollection(ownerVault: wallet)

            acct.save<@AFLMarketplace.SaleCollection>(<-sale , to: /storage/AFLSaleCollection)

            acct.link<&{AFLMarketplace.SalePublic}>(/public/AFLSaleCollection, target: /storage/AFLSaleCollection)
            
        }
        
        self.collectionRef = acct.borrow<&AFLNFT.Collection>(from: /storage/AFLNFTCollection)
                ??panic("could not borrow AFLNFT collection")
        self.AFLMarketplaceSaleCollectionRef = acct.borrow<&AFLMarketplace.SaleCollection>(from: /storage/AFLSaleCollection)
                ??panic("could not borrow AFLMarketplace collection")
    
    }

    execute {

        // withdraw the moment to put up for sale
        let token <- self.collectionRef.withdraw(withdrawID: momentID) as! @AFLNFT.NFT
        
        // the the moment for sale
        self.AFLMarketplaceSaleCollectionRef.listForSale(token: <-token, price: UFix64(price))
    }
}