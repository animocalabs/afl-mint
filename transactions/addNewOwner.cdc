import AFLPack from 0xa33d4223b3818e3f

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