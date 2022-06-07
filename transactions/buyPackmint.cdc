import AFLAdmin from 0x01cf0e2f2f715450
import AFLPack from 0x01cf0e2f2f715450
import FungibleToken from 0xee82856bf20e2aa6
import FlowToken from 0x0ae53cb6e3f42a79

transaction (accountAddress:Address) {
    // let adminRef: &AFLAdmin.Admin
    // let temproryVault : @FungibleToken.Vault

    prepare(account: AuthAccount){
        
        let account1 = getAccount(accountAddress)
        let adminRef = account1
                .getCapability<&{AFLPack.PackPublic}>(AFLPack.PackPublicPath)
                .borrow()
                ?? panic("Could not borrow admin reference")

        let vaultRef = account.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)
                ??panic("could not borrow vault")
        let temproryVault <- vaultRef.withdraw(amount: 49.0)

        adminRef.buyPack(templateId:2, receiptAddress:0x179b6b1cb6755e31, price:49.0, flowPayment: <- temproryVault)


    }
    execute{
    }

}