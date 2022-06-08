import FungibleToken from 0x0ae53cb6e3f42a79
import AFLMarketplace from 0x01cf0e2f2f715450
import AFLNFT from 0x01cf0e2f2f715450

// This transaction puts a moment owned by the user up for sale
// Parameters:
//
// tokenReceiverPath: token capability for the account who will receive tokens for purchase
// beneficiaryAccount: the Flow address of the account where a cut of the purchase will be sent
// cutPercentage: how much in percentage the beneficiary will receive from the sale
// momentID: ID of moment to be put on sale
// price: price of moment
transaction(tokenReceiverPath: PublicPath, beneficiaryAccount: Address, cutPercentage: UFix64, momentID: UInt64, price: UFix64) {

    // Local variables for the AFLNFT collection and AFLMarketplace sale collection objects
    let collectionRef: &AFLNFT.Collection
    let AFLMarketplaceSaleCollectionRef: &AFLMarketplace.SaleCollection
    
    prepare(acct: AuthAccount) {

        // check to see if a sale collection already exists
        if acct.borrow<&AFLMarketplace.SaleCollection>(from: /storage/AFLSaleCollection) == nil {

            // get the fungible token capabilities for the owner and beneficiary
            let ownerCapability = acct.getCapability(tokenReceiverPath)

            let beneficiaryCapability = getAccount(beneficiaryAccount).getCapability(tokenReceiverPath)

            // create a new sale collection
            let AFLNFTSaleCollection <- AFLMarketplace.createSaleCollection(ownerCapability: ownerCapability, beneficiaryCapability: beneficiaryCapability, cutPercentage: cutPercentage)
            
            // save it to storage
            acct.save(<-AFLNFTSaleCollection, to: /storage/AFLSaleCollection)
        
            // create a public link to the sale collection
            acct.link<&AFLMarketplace.SaleCollection{AFLMarketplace.SalePublic}>(/public/AFLSaleCollection, target: /storage/AFLSaleCollection)
        }
        
        // borrow a reference to the seller's moment collection
        self.collectionRef = acct.borrow<&AFLNFT.Collection>(from: /storage/AFLNFTCollection)
            ?? panic("Could not borrow from MomentCollection in storage")

        // borrow a reference to the sale
        self.AFLMarketplaceSaleCollectionRef = acct.borrow<&AFLMarketplace.SaleCollection>(from: /storage/AFLSaleCollection)
            ?? panic("Could not borrow from sale in storage")
    }

    execute {

        // withdraw the moment to put up for sale
        let token <- self.collectionRef.withdraw(withdrawID: momentID) as! @AFLNFT.NFT
        
        // the the moment for sale
        self.AFLMarketplaceSaleCollectionRef.listForSale(token: <-token, price: UFix64(price))
    }
}