import FungibleToken from 0x9a0766d93b6608b7
import AFLNFT from 0xf33e541cb9446d81
import AFLPack from 0xf33e541cb9446d81
import FlowToken from 0x7e60df042a9c0868

transaction (price: UFix64, tempIDs:[UInt64], packTemplateId: UInt64, receiptAddress: Address) {
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
        self.adminRef.buyPack(templateIds:tempIDs, packTemplateId: packTemplateId, receiptAddress:receiptAddress, price: price, flowPayment: <- self.temproryVault)
    }

}