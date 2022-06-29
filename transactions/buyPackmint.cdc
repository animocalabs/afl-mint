import FungibleToken from 0x9a0766d93b6608b7
import AFLNFT from 0xa33d4223b3818e3f
import AFLPack from 0xa33d4223b3818e3f
import FiatToken from 0xa983fecbed621163

transaction () {
    let adminRef: &AFLPack.Pack
    let temproryVault : @FungibleToken.Vault

    prepare(adminAccount: AuthAccount, tokenRecipientAccount: AuthAccount){
        
        self.adminRef = adminAccount.borrow<&AFLPack.Pack>(from: AFLPack.PackStoragePath)
            ??panic("could not borrow admin reference")
        
        let vaultRef = tokenRecipientAccount.borrow<&FiatToken.Vault>(from: FiatToken.VaultStoragePath)
                ??panic("could not borrow vault")

        self.temproryVault <- vaultRef.withdraw(amount: 49.0)

    }
    execute{

        self.adminRef.buyPack(templateIds:[1,2,3], receiptAddress:0x458eb22930f6f07c, price:49.0, flowPayment: <- self.temproryVault)

    }

}