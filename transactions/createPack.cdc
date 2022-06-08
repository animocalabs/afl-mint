
import AFLPack from 0x01cf0e2f2f715450


transaction(templateId:UInt64){
    let adminRef: &AFLPack.Pack
    prepare(acct: AuthAccount) {
        self.adminRef = acct.borrow<&AFLPack.Pack>(from:AFLPack.PackStoragePath)
        ??panic("could not borrow admin reference")
    }
    execute{
        // template id 2
        self.adminRef.createPack(templateId: templateId)
        log("pack created")

    }

}