import FungibleToken from 0x0ae53cb6e3f42a79
import AFLMarketplace from 0x01cf0e2f2f715450
import FlowToken from 0x0ae53cb6e3f42a79

// This transaction changes the percentage cut of a moment's sale given to beneficiary
// Parameters:
//
// newPercentage: new percentage of tokens the beneficiary will receive from the sale
transaction(newPercentage: UFix64) {

    // Local variable for the account's AFLNFT sale collection
    let AFLMarketplaceSaleCollectionRef: &AFLMarketplace.SaleCollection

    prepare(acct: AuthAccount) {

        let wallet =  acct.getCapability<&FlowToken.Vault{FungibleToken.Receiver}>(/public/flowTokenReceiver)
        let sale <- AFLMarketplace.createSaleCollection(ownerVault: wallet)
        acct.save<@AFLMarketplace.SaleCollection>(<-sale , to: /storage/AFLSaleCollection)
        
        // borrow a reference to the owner's sale collection
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