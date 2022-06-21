import FungibleToken from 0x9a0766d93b6608b7
import NonFungibleToken from 0x631e88ae7f1d7c20
import FlowToken from 0x7e60df042a9c0868
import AFLNFT from 0xa33d4223b3818e3f
import FiatToken from 0xa983fecbed621163

pub contract AFLPack {
     // event when a pack is created
    pub event PackCreated(templateId: UInt64)
    // event when a pack is bought
    pub event PackBought(templateId: UInt64, receiptAddress: Address?)
    // event when a pack is opened
    pub event PackOpened(nftId: UInt64, receiptAddress: Address?)
    // path for pack storage
    pub let PackStoragePath : StoragePath
    // path for pack public
    pub let PackPublicPath : PublicPath
     // dictionary to store pack data
    access(self) var allPacks: {UInt64: PackData}

    access(self) var ownerAddress: Address

    access(contract) let adminRef : Capability<&FiatToken.Vault{FungibleToken.Receiver}>

    pub struct PackData {
        pub let templateId:UInt64

        init(templateId:UInt64){
            self.templateId = templateId
        }
    }
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
        

        pub fun createPack(templateId:UInt64){
            pre {
                templateId != 0: "template id must not be zero"
                AFLPack.allPacks[templateId] == nil: "Pack already created with the given template id"
            }    
            let templateData = AFLNFT.getTemplateById(templateId: templateId)
            assert(templateData != nil, message: "data for given template id does not exist")
            // check all templates under the jukexbox are created or not
            var allNftTemplateExists = true;
            let templateImmutableData = templateData.getImmutableData()
            let allIds = templateImmutableData["nftTemplates"]! as! [AnyStruct]
            assert(allIds.length <= 10, message: "templates limit exceeded")
            // a temproary variable that will check the array repetation
            var temTemplateId : UInt64 = 0
            for tempID in allIds {
                
                if(UInt64(tempID as! Int)!=temTemplateId){
                temTemplateId = UInt64(tempID as! Int)

                var castedTempId = UInt64(tempID as! Int)
                let nftTemplateData = AFLNFT.getTemplateById(templateId: castedTempId)
                if(nftTemplateData == nil) {
                    allNftTemplateExists = false
                    break
                }
                }else{
                    allNftTemplateExists = false
                    break
                }
            }
            assert(allNftTemplateExists, message: "Invalid NFTs")
            let newpack = PackData(templateId: templateId)
            AFLPack.allPacks[templateId] = newpack
            emit PackCreated(templateId: templateId)
        }
        pub fun buyPack(templateId: UInt64, receiptAddress: Address, price: UFix64, flowPayment: @FungibleToken.Vault) {
            pre {
                price > 0.0: "Price should be greater than zero"
                templateId != 0 : "template id  must not be zero"
                flowPayment.balance == price: "Your vault does not have balance to buy NFT"
                receiptAddress != nil : "receipt address must not be null"
            }
            var templateData = AFLNFT.getTemplateById(templateId:templateId)
            assert(AFLPack.allPacks[templateData.templateId] != nil, message: "Pack is not registered") 
            let receiptAccount = getAccount(AFLPack.ownerAddress)
            let recipientCollection = receiptAccount
                .getCapability(FiatToken.VaultReceiverPubPath)
                .borrow<&FiatToken.Vault{FungibleToken.Receiver}>()
                ?? panic("Could not get receiver reference to the flow receiver")
            recipientCollection.deposit(from: <-flowPayment)

            AFLNFT.mintNFT(templateId: templateId, account: receiptAddress)
            emit PackBought(templateId: templateId, receiptAddress: receiptAddress)
            
        } 
        pub fun openPack(packNFT: @AFLNFT.NFT, receiptAddress: Address) {
            pre {
                packNFT != nil : "pack nft must not be null"
                receiptAddress != nil : "receipt address must not be null"
            }
            var packNFTData = AFLNFT.getNFTData(nftId: packNFT.id)
            var packTemplateData = AFLNFT.getTemplateById(templateId: packNFTData.templateId)
            let templateImmutableData = packTemplateData.getImmutableData()
            assert(AFLPack.allPacks[packNFTData.templateId] != nil, message: "Pack is not registered") 
            let allIds = templateImmutableData["nftTemplates"]! as! [AnyStruct]
            assert(allIds.length <= 10, message: "templates limit exceeded")
            for tempID in allIds {
                var castedTempId = UInt64(tempID as! Int)
                AFLNFT.mintNFT(templateId: castedTempId, account: receiptAddress)
            }
            emit PackOpened(nftId: packNFT.id, receiptAddress: self.owner?.address)
            destroy packNFT
        }
        init(){
        }
    }
    
    pub fun getAllPacks(): {UInt64: PackData} {
        pre {
            AFLPack.allPacks != nil: "pack does not exist"
        }
        return AFLPack.allPacks
    }

    pub fun getPackById(packId: UInt64): PackData {
        pre {
            AFLPack.allPacks[packId] != nil: "pack id does not exist"
        }
        return AFLPack.allPacks[packId]!
    }

    init() {
        self.ownerAddress = self.account!.address
        var adminRefCap =  self.account.getCapability<&FiatToken.Vault{FungibleToken.Receiver}>(FiatToken.VaultReceiverPubPath)
        self.adminRef = adminRefCap
        self.allPacks = {}
        self.PackStoragePath = /storage/AFLPack
        self.PackPublicPath = /public/AFLPack
        self.account.save(<- create Pack(), to: self.PackStoragePath)
        self.account.link<&{PackPublic}>(self.PackPublicPath, target: self.PackStoragePath)
    }
}