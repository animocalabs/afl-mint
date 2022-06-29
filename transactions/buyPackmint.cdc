import FungibleToken from 0x9a0766d93b6608b7
import AFLNFT from 0xf33e541cb9446d81
import AFLPack from 0xf33e541cb9446d81
import FiatToken from 0xa983fecbed621163

transaction () {
    let adminRef: &AFLPack.Pack
    let temproryVault : @FungibleToken.Vault

    prepare(adminAccount: AuthAccount, tokenRecipientAccount: AuthAccount){
        
        self.adminRef = adminAccount.borrow<&AFLPack.Pack>(from: AFLPack.PackStoragePath)
            ??panic("could not borrow admin reference")
        
        let vaultRef = tokenRecipientAccount.borrow<&FiatToken.Vault>(from: FiatToken.VaultStoragePath)
                ??panic("could not borrow vault")

        self.temproryVault <- vaultRef.withdraw(amount: 1.0)

    }
    execute{

        self.adminRef.buyPack(templateIds:[1,2,3], receiptAddress:0xf33e541cb9446d81, price:1.0, flowPayment: <- self.temproryVault)

    }

}