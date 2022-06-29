import AFLNFT from 0x01cf0e2f2f715450
import NonFungibleToken from 0x01cf0e2f2f715450

// This transaction transfers a template to a recipient
// This transaction is how a  user would transfer an NFT
// from their account to another account
// The recipient must have a TriQuetaNFT Collection object stored
// and a public TransferInterface capability stored at
// `/public/TemplateCollection`

// Parameters:
//
// recipient: The Flow address of the account to receive the NFT.
// withdrawID: The id of the NFT to be transferred
transaction(withdrawID: UInt64) {
    // local variable for storing the transferred token
    let transferToken: @NonFungibleToken.NFT
    prepare(acct: AuthAccount) {
        let collectionRef =  acct.borrow<&AFLNFT.Collection>(from: AFLNFT.CollectionStoragePath)
        ??panic("could not borrow a reference to the the stored nft Collection")
        self.transferToken <- collectionRef.withdraw(withdrawID: withdrawID)
    }

    execute {
        destroy self.transferToken
    }
}