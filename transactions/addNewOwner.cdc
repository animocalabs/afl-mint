import AFLPack from 0xf33e541cb9446d81

transaction(owner:Address){

    let adminRef: &AFLPack.Pack
    prepare(acct: AuthAccount) {
        self.adminRef = acct.borrow<&AFLPack.Pack>(from:AFLPack.PackStoragePath)
        ??panic("could not borrow admin reference")
    }
    execute{
        self.adminRef.updateOwnerAddress(owner: owner)

    }
}