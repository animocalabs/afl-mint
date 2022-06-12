import FungibleToken from 0x9a0766d93b6608b7
import FlowToken from 0x7e60df042a9c0868
import AFLMarketplace from 0x4ea480b0fc738e55
import AFLNFT from 0x4ea480b0fc738e55

transaction() {

    prepare(acct: AuthAccount) {

        let marketplaceCap = acct.getCapability<&{AFLMarketplace.SalePublic}>(/public/AFLSaleCollection)
        if !marketplaceCap.check(){
            let wallet =  acct.getCapability<&FlowToken.Vault{FungibleToken.Receiver}>(/public/flowTokenReceiver)
            let sale <- AFLMarketplace.createSaleCollection(ownerVault: wallet)

            acct.save<@AFLMarketplace.SaleCollection>(<-sale , to: /storage/AFLSaleCollection)

            acct.link<&{AFLMarketplace.SalePublic}>(/public/AFLSaleCollection, target: /storage/AFLSaleCollection)
        }
    
    }

    execute {
    }
}