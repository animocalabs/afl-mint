import FungibleToken from 0xee82856bf20e2aa6
import FlowToken from 0x0ae53cb6e3f42a79
import AFLNFT from 0x01cf0e2f2f715450
import AFLMarketplace from 0x01cf0e2f2f715450

// This transaction is for a user to purchase a AFL moment that another user
// has for sale in their sale collection
// Parameters
//
// sellerAddress: the Flow address of the account issuing the sale of a AFL moment
// tokenID: the ID of the AFL moment being purchased
// purchaseAmount: the amount for which the user is paying for the AFL moment; must not be less than the AFL moment's price
transaction(sellerAddress: Address, tokenID: UInt64, purchaseAmount: UFix64) {

    // Local variables for the AFLNFT collection object and token provider
    let collectionCap: Capability<&{AFLNFT.AFLNFTCollectionPublic}>
    let vaultCap: Capability<&FlowToken.Vault{FungibleToken.Receiver}>

    let temporaryVault: @FungibleToken.Vault
    
    prepare(acct: AuthAccount) {

         // get the references to the buyer''s Vault and NFT Collection receiver
        var collectionCap = acct.getCapability<&{AFLNFT.AFLNFTCollectionPublic}>(AFLNFT.CollectionPublicPath)

        // if collection is not created yet we make it.
        if !collectionCap.check() {
            // store an empty NFT Collection in account storage
            acct.save<@AFLNFT.Collection>(<- AFLNFT.createEmptyCollection(), to: AFLNFT.CollectionStoragePath)
            // publish a capability to the Collection in storage
            acct.link<&{AFLNFT.AFLNFTCollectionPublic}>(AFLNFT.CollectionPublicPath, target: AFLNFT.CollectionStoragePath)
        }

        self.collectionCap = collectionCap
        self.vaultCap = acct.getCapability<&FlowToken.Vault{FungibleToken.Receiver}>(/public/flowTokenReceiver)

        let vaultRef = acct.borrow<&FlowToken.Vault{FungibleToken.Provider}>(from: /storage/flowTokenVault) ?? panic("Could not borrow owner''s Vault reference")

        // withdraw tokens from the buyer''s Vault
        self.temporaryVault <- vaultRef.withdraw(amount: purchaseAmount)
    }

    execute {

        let seller = getAccount(sellerAddress)

        // borrow a public reference to the seller's sale collection
        let marketplace = seller.getCapability(/public/AFLSaleCollection)
            .borrow<&{AFLMarketplace.SalePublic}>()
            ?? panic("Could not borrow public sale reference")
        
        marketplace.purchase(tokenID:tokenID, recipientCap:self.collectionCap, buyTokens: <- self.temporaryVault)
    }
}
