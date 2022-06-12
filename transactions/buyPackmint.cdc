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

        self.adminRef.buyPack(templateId: templateId, receiptAddress: receiptAddress, price: price, flowPayment: <- self.temproryVault)

    }

}