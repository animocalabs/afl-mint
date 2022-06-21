import FungibleToken from 0x9a0766d93b6608b7
import FlowToken from 0x7e60df042a9c0868
import AFLAdmin from 0xa33d4223b3818e3f

transaction(templateId: UInt64, account:Address){

    prepare(acct: AuthAccount) {
        let adminRef = acct.borrow<&AFLAdmin.Admin>(from: /storage/AFLAdmin)
            ??panic("could not borrow reference")

        adminRef.openPack( templateId: templateId, account: account)
    }
}