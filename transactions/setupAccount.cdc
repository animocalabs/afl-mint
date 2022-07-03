
import AFLNFT from 0xf33e541cb9446d81
transaction {
    prepare(acct: AuthAccount) {
          // First, check to see if a moment collection already exists
        if acct.borrow<&AFLNFT.Collection>(from: AFLNFT.CollectionStoragePath) == nil{
        let collection  <- AFLNFT.createEmptyCollection() as! @AFLNFT.Collection
        // store the empty NFT Collection in account storage
        acct.save( <- collection, to:AFLNFT.CollectionStoragePath)
        log("Collection created for account".concat(acct.address.toString()))
        // create a public capability for the Collection
        acct.link<&{AFLNFT.AFLNFTCollectionPublic}>(AFLNFT.CollectionPublicPath, target:AFLNFT.CollectionStoragePath)
        log("Capability created")
        }
    }
}