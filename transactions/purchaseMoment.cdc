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
    let collectionRef: &AFLNFT.Collection
    let providerRef: &FlowToken.Vault{FungibleToken.Provider}
    
    prepare(acct: AuthAccount) {

        // borrow a reference to the signer's collection
        self.collectionRef = acct.borrow<&AFLNFT.Collection>(from: /storage/AFLNFTCollection)
            ?? panic("Could not borrow reference to the AFLNFT Collection")

        // borrow a reference to the signer's fungible token Vault
        self.providerRef = acct.borrow<&FlowToken.Vault{FungibleToken.Provider}>(from: /storage/flowTokenProviders)!   
    }

    execute {

        // withdraw tokens from the signer's vault
        let tokens <- self.providerRef.withdraw(amount: purchaseAmount) as! @FlowToken.Vault

        // get the seller's public account object
        let seller = getAccount(sellerAddress)

        // borrow a public reference to the seller's sale collection
        let AFLMarketplaceSaleCollection = seller.getCapability(/public/AFLSaleCollection)
            .borrow<&{AFLMarketplace.SalePublic}>()
            ?? panic("Could not borrow public sale reference")
    
        // purchase the AFL moment
        let purchasedToken <- AFLMarketplaceSaleCollection.purchase(tokenID: tokenID, buyTokens: <-tokens)

        // deposit the purchased AFL moment into the signer's collection
        self.collectionRef.deposit(token: <-purchasedToken)
    }
}