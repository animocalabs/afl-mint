
import AFLAdmin from 0x01cf0e2f2f715450
transaction(maxSupply:UInt64) {

    prepare(acct: AuthAccount) {
        let adminRef = acct.borrow<&AFLAdmin.Admin>(from: /storage/AFLAdmin)
            ??panic("could not borrow reference")

        let immutableData : {String: AnyStruct} = {
            "nftContent"        : "Image",
            "contentType"       : "https://www.dropbox.com/s/c6y2otoofiz6bzm/2022_RIPPER_SKIPPER_COMMON_BACK.jpg?dl=0",
            "title"             : "2022_RIPPER_SKIPPER_COMMON_BACK",
            "competition"       : "AFL",
            "date"              : "2022-5-26",
            "round"             : "Round 7",
            "home team"         : "Essendon",
            "away team"         : "Carlton",
            "stadium location"  : "MCG, Melbourne",
            "Players Involved"  : "Patrick Cripps",
            "headline"          : "Captain Cripps nails centre-bounce classic",
            "Description"       : "Carlton skipper Patrick Cripps bursts from the clearance and kicks a crucial goal against Essendon",
            "collectionName"    : "Ripper Skipper",
            "tier"              : "Common"
        }
        adminRef.createTemplate( maxSupply: maxSupply, immutableData: immutableData)
    }
}