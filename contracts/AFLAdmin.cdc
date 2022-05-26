import AFLNFT from 0x01cf0e2f2f715450
import AFLPack from 0x01cf0e2f2f715450
import FungibleToken from 0xee82856bf20e2aa6
pub contract AFLAdmin {

    // Admin
    // the admin resource is defined so that only the admin account
    // can have this resource. It possesses the ability to open packs
    // given a user's Pack Collection and Card Collection reference.
    // It can also create a new pack type and mint Packs.
    //
    pub resource Admin {

        pub fun createTemplate(maxSupply:UInt64, immutableData:{String: AnyStruct}){
            AFLNFT.createTemplate(maxSupply:maxSupply, immutableData:immutableData)
        }
        
        pub fun buyPack(templateId: UInt64, account: Address, price: UFix64, flowPayment: @FungibleToken.Vault){
            AFLPack.buyPack(templateId:templateId, receiptAddress:account, price:price, flowPayment: <-flowPayment)
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
        self.account.save(<- create Admin(), to: /storage/AFLAdmin)
    }
}