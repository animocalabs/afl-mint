import AFLAdmin from 0x01cf0e2f2f715450
import FungibleToken from 0xee82856bf20e2aa6
import FlowToken from 0x0ae53cb6e3f42a79

transaction {
    let adminRef: &AFLAdmin.Admin
    let temproryVault : @FungibleToken.Vault

    prepare(account: AuthAccount){
        
        self.adminRef = account.borrow<&AFLAdmin.Admin>(from: /storage/AFLAdmin)
                        ??panic("could not borrow")
        
        let vaultRef = account.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)
                ??panic("could not borrow vault")
        self.temproryVault <- vaultRef.withdraw(amount: 49.0)


    }
    execute{
        self.adminRef.buyPack(templateId:4, account:0x179b6b1cb6755e31, price:49.0, flowPayment: <- self.temproryVault)
    }

}