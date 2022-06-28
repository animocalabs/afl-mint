import AFLAdmin from 0x01cf0e2f2f715450
import AFLPack from 0x01cf0e2f2f715450
import FungibleToken from 0xee82856bf20e2aa6
import FlowToken from 0x0ae53cb6e3f42a79

transaction () {
    let adminRef: &AFLPack.Pack
    let temproryVault : @FungibleToken.Vault

    prepare(adminAccount: AuthAccount, tokenRecipientAccount: AuthAccount){
        
        self.adminRef = adminAccount.borrow<&AFLPack.Pack>(from: AFLPack.PackStoragePath)
            ??panic("could not borrow admin reference")
        
        let vaultRef = tokenRecipientAccount.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)
                ??panic("could not borrow vault")

        self.temproryVault <- vaultRef.withdraw(amount: 49.0)

    }
    execute{

        self.adminRef.buyPack(templateIds:[1,2,3], receiptAddress:0x179b6b1cb6755e31, price:49.0, flowPayment: <- self.temproryVault)

    }

}