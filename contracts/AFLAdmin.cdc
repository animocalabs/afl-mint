import AFLNFT from 0xa33d4223b3818e3f
import AFLPack from 0xa33d4223b3818e3f
import FungibleToken from 0x9a0766d93b6608b7
pub contract AFLAdmin {

    // Paths
    pub let AdminStoragePath: StoragePath
    // Admin
    // the admin resource is defined so that only the admin account
    // can have this resource. It possesses the ability to open packs
    // given a user's Pack Collection reference.
    //
    pub resource Admin {

        pub fun createTemplate(maxSupply:UInt64, immutableData:{String: AnyStruct}){
            AFLNFT.createTemplate(maxSupply:maxSupply, immutableData:immutableData)
        }

        pub fun openPack(templateId: UInt64, account: Address){
            AFLNFT.mintNFT(templateId:templateId, account:account)
        }
        // createAdmin
        // only an admin can ever create
        // a new Admin resource
        //
        pub fun createAdmin(): @Admin {
            return <- create Admin()
        }

        init() {
            
        }
    }

    init() {
        self.AdminStoragePath = /storage/AFLAdmin
        self.account.save(<- create Admin(), to:  self.AdminStoragePath)
    }
}