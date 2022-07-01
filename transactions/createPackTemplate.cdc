
import AFLAdmin from 0xf33e541cb9446d81
transaction(maxSupply:UInt64) {

    prepare(acct: AuthAccount) {
        let adminRef = acct.borrow<&AFLAdmin.Admin>(from: /storage/AFLAdmin)
            ??panic("could not borrow reference")
        let nftTemplateIds : [AnyStruct] = [1,2,3,5]
        
        let immutableData : {String: AnyStruct} = {
            "image"       : "https://www.dropbox.com/s/0jj5vezwwck6pc2/2022_RIPPER_SKIPPER_P_CRIPPS_THUMB_C_1.jpg?dl=0",
            "nftTemplates": nftTemplateIds      
        }
        adminRef.createTemplate( maxSupply: maxSupply, immutableData: immutableData)

    }
}