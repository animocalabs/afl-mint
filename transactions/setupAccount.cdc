
import AFLNFT from 0xa33d4223b3818e3f
transaction {
    prepare(acct: AuthAccount) {

        let collection  <- AFLNFT.createEmptyCollection() as! @AFLNFT.Collection
        // store the empty NFT Collection in account storage
        acct.save( <- collection, to:AFLNFT.CollectionStoragePath)
        log("Collection created for account".concat(acct.address.toString()))
        // create a public capability for the Collection
        acct.link<&{AFLNFT.AFLNFTCollectionPublic}>(AFLNFT.CollectionPublicPath, target:AFLNFT.CollectionStoragePath)
        log("Capability created")

    }
}