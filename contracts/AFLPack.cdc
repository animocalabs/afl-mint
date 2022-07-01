import FungibleToken from 0x9a0766d93b6608b7
import NonFungibleToken from 0x631e88ae7f1d7c20
import AFLNFT from 0xf33e541cb9446d81
import FiatToken from 0xa983fecbed621163

pub contract AFLPack {
    // event when a pack is bought
    pub event PackBought(templateId: UInt64, receiptAddress: Address?)
    // event when a pack is opened
    pub event PackOpened(nftId: UInt64, receiptAddress: Address?)
    // path for pack storage
    pub let PackStoragePath : StoragePath
    // path for pack public
    pub let PackPublicPath : PublicPath

    access(self) var ownerAddress: Address

    access(contract) let adminRef : Capability<&FiatToken.Vault{FungibleToken.Receiver}>

    pub resource interface PackPublic {
        // making this function public to call by authorized users
        pub fun openPack(packNFT: @AFLNFT.NFT, receiptAddress: Address)
    }
    pub resource Pack : PackPublic {

        pub fun updateOwnerAddress(owner:Address){
            pre{
                owner != nil: "owner must not be null"
            }
            AFLPack.ownerAddress = owner
        }
        
        pub fun buyPack(templateIds: [UInt64], packTemplateId: UInt64, receiptAddress: Address, price: UFix64, flowPayment: @FungibleToken.Vault) {
            pre {
                price > 0.0: "Price should be greater than zero"
                templateIds.length > 0 : "template ids array length should be greater than zero"
                flowPayment.balance == price: "Your vault does not have balance to buy NFT"
                receiptAddress != nil : "receipt address must not be null"
                packTemplateId != 0 : "pack template id must not be zero"
            }
            var allNftTemplateExists = true;
            assert(templateIds.length <= 10, message: "templates limit exceeded")
            let nftTemplateIds : [AnyStruct] = []
            for tempID in templateIds {

                let nftTemplateData = AFLNFT.getTemplateById(templateId: tempID)
                if(nftTemplateData == nil) {
                    allNftTemplateExists = false
                    break
                }
                nftTemplateIds.append(tempID)
            }
            
            let packData = AFLNFT.getTemplateById(templateId: packTemplateId)
            let packImmutableData = packData.getImmutableData()
            packImmutableData["nftTemplates"] = nftTemplateIds
            



            assert(allNftTemplateExists, message: "Invalid NFTs")
            AFLNFT.createTemplate(maxSupply: 1, immutableData: packImmutableData)

            let lastIssuedTemplateId = AFLNFT.getLatestTemplateId()
            let receiptAccount = getAccount(AFLPack.ownerAddress)
            let recipientCollection = receiptAccount
                .getCapability(FiatToken.VaultReceiverPubPath)
                .borrow<&FiatToken.Vault{FungibleToken.Receiver}>()
                ?? panic("Could not get receiver reference to the flow receiver")
            recipientCollection.deposit(from: <-flowPayment)

            AFLNFT.mintNFT(templateId: lastIssuedTemplateId, account: receiptAddress)
            emit PackBought(templateId: lastIssuedTemplateId, receiptAddress: receiptAddress)
        } 
        pub fun openPack(packNFT: @AFLNFT.NFT, receiptAddress: Address) {
            pre {
                packNFT != nil : "pack nft must not be null"
                receiptAddress != nil : "receipt address must not be null"
            }
            var packNFTData = AFLNFT.getNFTData(nftId: packNFT.id)
            var packTemplateData = AFLNFT.getTemplateById(templateId: packNFTData.templateId)
            let templateImmutableData = packTemplateData.getImmutableData()

            let allIds = templateImmutableData["nftTemplates"]! as! [AnyStruct]
            assert(allIds.length <= 10, message: "templates limit exceeded")
            for tempID in allIds {
                AFLNFT.mintNFT(templateId: tempID as! UInt64, account: receiptAddress)
            }
            emit PackOpened(nftId: packNFT.id, receiptAddress: self.owner?.address)
            destroy packNFT
        }
        init(){
        }
    }
    init() {
        self.ownerAddress = self.account!.address
        var adminRefCap =  self.account.getCapability<&FiatToken.Vault{FungibleToken.Receiver}>(FiatToken.VaultReceiverPubPath)
        self.adminRef = adminRefCap
        self.PackStoragePath = /storage/AFLPack
        self.PackPublicPath = /public/AFLPack
        self.account.save(<- create Pack(), to: self.PackStoragePath)
        self.account.link<&{PackPublic}>(self.PackPublicPath, target: self.PackStoragePath)
    }
}