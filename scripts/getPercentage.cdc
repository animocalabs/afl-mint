import AFLMarketplace from 0x01cf0e2f2f715450

pub fun main(account:Address):UFix64{
    let account1 = getAccount(account)
    let marketplaceCap = account1.getCapability(/public/AFLSaleCollection)
                        .borrow<&{AFLMarketplace.SalePublic}>()
                        ??panic("could not borrow receiver reference ")
                        
    return  marketplaceCap.getPercentage()
}