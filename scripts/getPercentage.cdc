import AFLMarketplace from 0x4ea480b0fc738e55

pub fun main(account:Address):UFix64{
    let account1 = getAccount(account)
    let marketplaceCap = account1.getCapability(/public/AFLSaleCollection)
                        .borrow<&{AFLMarketplace.SalePublic}>()
                        ??panic("could not borrow receiver reference ")
                        
    return  marketplaceCap.getPercentage()
}