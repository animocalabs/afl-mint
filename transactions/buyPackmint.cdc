import FungibleToken from 0x9a0766d93b6608b7
import FlowToken from 0x7e60df042a9c0868
import AFLNFT from 0x4ea480b0fc738e55
import AFLPack from 0x4ea480b0fc738e55

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

        self.adminRef.buyPack(templateIds:[1,2,3], receiptAddress:0x458eb22930f6f07c, price:49.0, flowPayment: <- self.temproryVault)

    }

}