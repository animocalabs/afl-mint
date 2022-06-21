
import AFLAdmin from 0xa33d4223b3818e3f
transaction(maxSupply:UInt64) {

    prepare(acct: AuthAccount) {
        let adminRef = acct.borrow<&AFLAdmin.Admin>(from: /storage/AFLAdmin)
            ??panic("could not borrow reference")
        let nftTemplateIds : [AnyStruct] = [1,2,3]
        
        let immutableData : {String: AnyStruct} = {
            "image"       : "https://www.dropbox.com/s/0jj5vezwwck6pc2/2022_RIPPER_SKIPPER_P_CRIPPS_THUMB_C_1.jpg?dl=0",
            "nftTemplates": nftTemplateIds      
        }
        adminRef.createTemplate( maxSupply: maxSupply, immutableData: immutableData)

    }
}