import FungibleToken from 0xee82856bf20e2aa6
import NonFungibleToken from 0x01cf0e2f2f715450
import FlowToken from 0x0ae53cb6e3f42a79
import AFLPack from 0x01cf0e2f2f715450
import AFLNFT from 0x01cf0e2f2f715450

pub contract AFLMarketplace {
    // The Vault of the Marketplace where it will receive the cuts on each sale
    access(contract) let marketplaceWallet: Capability<&FlowToken.Vault{FungibleToken.Receiver}>
    // Event that is emitted when a new NFT is put up for sale
    pub event ForSale(id: UInt64, price: UFix64, owner: Address?)
    // Event that is emitted when the price of an NFT changes
    pub event PriceChanged(id: UInt64, newPrice: UFix64, owner: Address?)
     // Event that is emitted when a token is purchased
    pub event TokenPurchased(id: UInt64, price: UFix64, owner: Address?, to: Address?)
    // Event that is emitted when a seller withdraws their NFT from the sale
    pub event SaleCanceled(id: UInt64, owner: Address?)
    // emitted when the cut percentage of the sale has been changed by the owner
    pub event CutPercentageChanged(newPercent: UFix64, owner: Address?)

    // SalePublic 
    //
    // The interface that a user can publish a capability to their sale
    // to allow others to access their sale
    pub resource interface SalePublic {
        pub fun purchase(tokenID: UInt64, recipientCap: Capability<&{AFLNFT.AFLNFTCollectionPublic}>, buyTokens: @FungibleToken.Vault)
        pub fun getPrice(tokenID: UInt64): UFix64?
        pub fun getPercentage(): UFix64
        pub fun getIDs(): [UInt64]
        pub fun borrowMoment(id: UInt64): &AFLNFT.NFT? {
            // If the result isn't nil, the id of the returned reference
            // should be the same as the argument to the function
            post {
                (result == nil) || (result?.id == id): 
                    "Cannot borrow Moment reference: The ID of the returned reference is incorrect"
            }
        }
    }

    // SaleCollection
    //
    // This is the main resource that token sellers will store in their account
    // to manage the NFTs that they are selling. 
    // NFT Collection object that allows a user to put their NFT up for sale
    // where others can send fungible tokens to purchase it
    //
    pub resource SaleCollection: SalePublic {
        
        // Dictionary of the NFTs that the user is putting up for sale
        pub var forSale: @{UInt64: AFLNFT.NFT}
        // Dictionary of the flow prices for each NFT by ID
        access(self) var prices: {UInt64: UFix64}

        // The fungible token vault of the owner of this sale.
        // When someone buys a token, this resource can deposit
        // tokens into their account.
        access(account) let ownerVault: Capability<&FlowToken.Vault{FungibleToken.Receiver}>

        // The percentage that is taken from every purchase for the beneficiary
        // For example, if the percentage is 10%, cutPercentage = 0.10
        pub var cutPercentage: UFix64

        init (vault: Capability<&FlowToken.Vault{FungibleToken.Receiver}>) {
            pre {
                // Check that both capabilities are for fungible token Vault receivers
                vault.check(): 
                    "Owner's Receiver Capability is invalid!"
            }
            
            // create an empty collection to store the moments that are for sale
            self.forSale <-{}
            self.ownerVault = vault
            // prices are initially empty because there are no moments for sale
            self.prices = {}
            self.cutPercentage = 0.10
        }

        // listForSale lists an NFT for sale in this sale collection
        // at the specified price
        //
        // Parameters: token: The NFT to be put up for sale
        //             price: The price of the NFT
        pub fun listForSale(token: @AFLNFT.NFT, price: UFix64) {

            // get the ID of the token
            let id = token.id

            // Set the token's price
            self.prices[token.id] = price


            let oldToken <- self.forSale[id] <- token

            destroy oldToken

            emit ForSale(id: id, price: price, owner: self.owner?.address)
        }

        // Withdraw removes a moment that was listed for sale
        // and clears its price
        //
        // Parameters: tokenID: the ID of the token to withdraw from the sale
        //
        // Returns: @AFLNFT.NFT: The nft that was withdrawn from the sale
        pub fun withdraw(tokenID: UInt64): @AFLNFT.NFT {
            // remove the price
            self.prices.remove(key: tokenID)
            // remove and return the token
            let token <- self.forSale.remove(key: tokenID) ?? panic("missing NFT")

            emit SaleCanceled(id: tokenID, owner: self.owner!.address)
            return <-token
        }

        // purchase lets a user send tokens to purchase an NFT that is for sale
        // the purchased NFT is returned to the transaction context that called it
        //
        // Parameters: tokenID: the ID of the NFT to purchase
        //             butTokens: the fungible tokens that are used to buy the NFT

        pub fun purchase(tokenID: UInt64, recipientCap: Capability<&{AFLNFT.AFLNFTCollectionPublic}>, buyTokens: @FungibleToken.Vault) {
            pre {
                self.forSale[tokenID] != nil && self.prices[tokenID] != nil:
                    "No token matching this ID for sale!"           
                buyTokens.balance >= (self.prices[tokenID] ?? UFix64(0)):
                    "Not enough tokens to buy the NFT!"
            }

            let recipient = recipientCap.borrow()!


            // Read the price for the token
            let price = self.prices[tokenID]!

            // Set the price for the token to nil
            self.prices[tokenID] = nil

            let vaultRef = self.ownerVault.borrow() ??panic("could not borrow reference to the owner vault")

            let token <- self.withdraw(tokenID: tokenID)

            let marketplaceWallet = AFLMarketplace.marketplaceWallet.borrow()!
            let marketplaceAmount = price * self.cutPercentage
            let tempMarketplaceWallet <- buyTokens.withdraw(amount: marketplaceAmount)
            marketplaceWallet.deposit(from: <- tempMarketplaceWallet)

            vaultRef.deposit(from: <- buyTokens)

            recipient.deposit(token: <- token)


            emit TokenPurchased(id: tokenID, price: price, owner: self.owner?.address, to: recipient.owner!.address)
        }

        // changePrice changes the price of a token that is currently for sale
        //
        // Parameters: tokenID: The ID of the NFT's price that is changing
        //             newPrice: The new price for the NFT
        pub fun changePrice(tokenID: UInt64, newPrice: UFix64) {
            pre {
                self.prices[tokenID] != nil: "Cannot change the price for a token that is not for sale"
            }
            // Set the new price
            self.prices[tokenID] = newPrice

            emit PriceChanged(id: tokenID, newPrice: newPrice, owner: self.owner?.address)
        }

        // changePercentage changes the cut percentage of the tokens that are for sale
        //
        // Parameters: newPercent: The new cut percentage for the sale
        pub fun changePercentage(_ newPercent: UFix64) {
            pre {
                newPercent <= 1.0: "Cannot set cut percentage to greater than 100%"
            }
            self.cutPercentage = newPercent

            emit CutPercentageChanged(newPercent: newPercent, owner: self.owner?.address)
        }

        // getPrice returns the price of a specific token in the sale
        // 
        // Parameters: tokenID: The ID of the NFT whose price to get
        //
        // Returns: UFix64: The price of the token
        pub fun getPrice(tokenID: UInt64): UFix64? {
            return self.prices[tokenID]
        }

        pub fun getPercentage(): UFix64 {
            return self.cutPercentage
            
        }

        // getIDs returns an array of token IDs that are for sale
        pub fun getIDs(): [UInt64] {
            return self.forSale.keys
        }

        // borrowMoment Returns a borrowed reference to a Moment in the collection
        // so that the caller can read data from it
        //
        // Parameters: id: The ID of the moment to borrow a reference to
        //
        // Returns: &AFL.NFT? Optional reference to a moment for sale 
        //                        so that the caller can read its data
        //
        pub fun borrowMoment(id: UInt64): &AFLNFT.NFT? {
            if self.forSale[id] != nil{
                return (&self.forSale[id] as &AFLNFT.NFT?)!
            }
            else {
                return  nil   
            }
        }

        // If the sale collection is destroyed, 
        // destroy the tokens that are for sale inside of it
        destroy() {
            destroy self.forSale
        }
    }

    // createCollection returns a new collection resource to the caller
    pub fun createSaleCollection(ownerVault: Capability<&FlowToken.Vault{FungibleToken.Receiver}>): @SaleCollection {
        return <- create SaleCollection(vault: ownerVault)
    }

    init(){
        self.marketplaceWallet = self.account.getCapability<&FlowToken.Vault{FungibleToken.Receiver}>(/public/flowTokenReceiver)

    }
}