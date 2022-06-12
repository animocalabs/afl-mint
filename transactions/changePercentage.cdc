import FungibleToken from 0x9a0766d93b6608b7
import FlowToken from 0x7e60df042a9c0868
import AFLMarketplace from 0x4ea480b0fc738e55

// This transaction changes the percentage cut of a moment's sale given to beneficiary
// Parameters:
//
// newPercentage: new percentage of tokens the beneficiary will receive from the sale
transaction(newPercentage: UFix64) {

    // Local variable for the account's AFLNFT sale collection
    let AFLMarketplaceSaleCollectionRef: &AFLMarketplace.SaleCollection

    prepare(acct: AuthAccount) {
        let marketplaceCap = acct.getCapability<&{AFLMarketplace.SalePublic}>(/public/AFLSaleCollection)
        if !marketplaceCap.check() {

        let wallet =  acct.getCapability<&FlowToken.Vault{FungibleToken.Receiver}>(/public/flowTokenReceiver)
        let sale <- AFLMarketplace.createSaleCollection(ownerVault: wallet)
        
        acct.save<@AFLMarketplace.SaleCollection>(<-sale , to: /storage/AFLSaleCollection)
        
        // borrow a reference to the owner's sale collection
        }
        self.AFLMarketplaceSaleCollectionRef = acct.borrow<&AFLMarketplace.SaleCollection>(from: /storage/AFLSaleCollection)
            ?? panic("Could not borrow from sale in storage")
    }

    execute {

        // Change the percentage of the moment
        self.AFLMarketplaceSaleCollectionRef.changePercentage(newPercentage)
    }

    post {

        self.AFLMarketplaceSaleCollectionRef.cutPercentage! == newPercentage: 
            "cutPercentage not changed"
    }
    
}