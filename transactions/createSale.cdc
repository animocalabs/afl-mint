import AFLMarketplace from 0x01cf0e2f2f715450

// This transaction creates a public sale collection capability that any user can interact with
// Parameters:
//
// tokenReceiverPath: token capability for the account who will receive tokens for purchase
// beneficiaryAccount: the Flow address of the account where a cut of the purchase will be sent
// cutPercentage: how much in percentage the beneficiary will receive from the sale
transaction(tokenReceiverPath: PublicPath, beneficiaryAccount: Address, cutPercentage: UFix64) {

    prepare(acct: AuthAccount) {
        
        let ownerCapability = acct.getCapability(tokenReceiverPath)

        let beneficiaryCapability = getAccount(beneficiaryAccount).getCapability(tokenReceiverPath)

        let collection <- AFLMarketplace.createSaleCollection(ownerCapability: ownerCapability, beneficiaryCapability: beneficiaryCapability, cutPercentage: cutPercentage)
        
        acct.save(<-collection, to: /storage/AFLSaleCollection)
        
        acct.link<&AFLMarketplace.SaleCollection{AFLMarketplace.SalePublic}>(/public/AFLSaleCollection, target: /storage/AFLSaleCollection)
    }
}