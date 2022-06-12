import AFLPack from 0x4ea480b0fc738e55

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