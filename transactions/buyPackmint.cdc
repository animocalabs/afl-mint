import FungibleToken from 0x9a0766d93b6608b7
import AFLNFT from 0xa33d4223b3818e3f
import AFLPack from 0xa33d4223b3818e3f
import FiatToken from 0xa983fecbed621163

transaction (templateId:UInt64, receiptAddress:Address, price: UFix64) {
    let adminRef: &AFLPack.Pack
    let temproryVault : @FungibleToken.Vault

    prepare(adminAccount: AuthAccount, tokenRecipientAccount: AuthAccount){
        
        self.adminRef = adminAccount.borrow<&AFLPack.Pack>(from: AFLPack.PackStoragePath)
            ??panic("could not borrow admin reference")
        
        let vaultRef = tokenRecipientAccount.borrow<&FiatToken.Vault>(from: FiatToken.VaultStoragePath)
                ??panic("could not borrow vault")

        self.temproryVault <- vaultRef.withdraw(amount: price)

    }
    execute{

        self.adminRef.buyPack(templateId: templateId, receiptAddress: receiptAddress, price: price, flowPayment: <- self.temproryVault)

    }

}