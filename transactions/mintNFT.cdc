import FungibleToken from 0xee82856bf20e2aa6
import FlowToken from 0x0ae53cb6e3f42a79   
import AFLAdmin from 0x01cf0e2f2f715450

transaction(templateId: UInt64, account:Address){

    prepare(acct: AuthAccount) {
        let adminRef = acct.borrow<&AFLAdmin.Admin>(from: /storage/AFLAdmin)
            ??panic("could not borrow reference")

        adminRef.openPack( templateId: templateId, account: account)
        log("Template created")
    }
}