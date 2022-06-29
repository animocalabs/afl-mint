import FungibleToken from 0x9a0766d93b6608b7
import FlowToken from 0x7e60df042a9c0868
import AFLNFT from 0x4ea480b0fc738e55
import AFLPack from 0x4ea480b0fc738e55

transaction (templateId:UInt64, receiptAddress:Address, price: UFix64) {
    let adminRef: &AFLPack.Pack
    let temproryVault : @FungibleToken.Vault

    prepare(adminAccount: AuthAccount, tokenRecipientAccount: AuthAccount){
        
        self.adminRef = adminAccount.borrow<&AFLPack.Pack>(from: AFLPack.PackStoragePath)
            ??panic("could not borrow admin reference")
        
        let vaultRef = tokenRecipientAccount.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)
                ??panic("could not borrow vault")

        self.temproryVault <- vaultRef.withdraw(amount: price)

    }
    execute{

        self.adminRef.buyPack(templateIds:[1,2,3], receiptAddress:0x179b6b1cb6755e31, price:49.0, flowPayment: <- self.temproryVault)

    }

}