import AFLMarketplace from 0x01cf0e2f2f715450

transaction(tokenID: UInt64, newPrice:UFix64){

    let AFLMarketplaceSaleCollectionRef : &AFLMarketplace.SaleCollection

    prepare(account:AuthAccount){

        self.AFLMarketplaceSaleCollectionRef = account.borrow<&AFLMarketplace.SaleCollection>(from: /storage/AFLSaleCollection)
            ??panic("could not borrow sale collection")

    }
    execute{
        self.AFLMarketplaceSaleCollectionRef.changePrice(tokenID: tokenID, newPrice: newPrice)

    }


}