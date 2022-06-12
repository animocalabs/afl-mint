
import AFLNFT from 0x4ea480b0fc738e55
transaction {
    prepare(acct: AuthAccount) {

        let collection  <- AFLNFT.createEmptyCollection()
        // store the empty NFT Collection in account storage
        acct.save( <- collection, to:AFLNFT.CollectionStoragePath)
        log("Collection created for account".concat(acct.address.toString()))
        // create a public capability for the Collection
        acct.link<&{AFLNFT.AFLNFTCollectionPublic}>(AFLNFT.CollectionPublicPath, target:AFLNFT.CollectionStoragePath)
        log("Capability created")

    }
}