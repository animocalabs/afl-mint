
import NonFungibleToken from 0x01cf0e2f2f715450
import FlowToken from 0x0ae53cb6e3f42a79
import AFLNFT from 0x01cf0e2f2f715450
import FungibleToken from 0xee82856bf20e2aa6

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

    access(contract) let adminRef : Capability<&FlowToken.Vault{FungibleToken.Receiver}>

    pub struct PackData {
        pub let templateId:UInt64

        init(templateId:UInt64){
            self.templateId = templateId
        }
    }
    pub resource interface PackPublic {
        // making this function public to call by other users
        pub fun openPack(packNFT: @NonFungibleToken.NFT, receiptAddress: Address)
    }
    pub resource Pack : PackPublic {

        pub fun createPack(templateId:UInt64){
            pre {
                templateId != nil: "template id must not be null"
                AFLPack.allPacks[templateId] == nil: "Pacl already created with the given template id"
            }    
            let templateData = AFLNFT.getTemplateById(templateId: templateId)
            assert(templateData != nil, message: "data for given template id does not exist")
            // check all templates under the jukexbox are created or not
            var allNftTemplateExists = true;
            let templateImmutableData = templateData.getImmutableData()
            let allIds = templateImmutableData["nftTemplates"]! as! [AnyStruct]
            assert(allIds.length <= 3, message: "templates limit exceeded")
            for tempID in allIds {
                var castedTempId = UInt64(tempID as! Int)
                let nftTemplateData = AFLNFT.getTemplateById(templateId: castedTempId)
                if(nftTemplateData == nil) {
                    allNftTemplateExists = false
                    break
                }
            }
            assert(allNftTemplateExists, message: "Invalid NFTs")
            let newpack = PackData(templateId: templateId)
            AFLPack.allPacks[templateId] = newpack
            emit PackCreated(templateId: templateId)
        }
        
        pub fun openPack(packNFT: @NonFungibleToken.NFT, receiptAddress: Address) {
            pre {
                packNFT != nil : "pack nft must not be null"
                receiptAddress != nil : "receipt address must not be null"
            }
            var packNFTData = AFLNFT.getNFTData(nftId: packNFT.id)
            var packTemplateData = AFLNFT.getTemplateById(templateId: packNFTData.templateId)
            let templateImmutableData = packTemplateData.getImmutableData()
            let allIds = templateImmutableData["nftTemplates"]! as! [AnyStruct]
            assert(allIds.length <= 3, message: "templates limit exceeded")
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
    access(account) fun buyPack(templateId: UInt64, receiptAddress: Address, price: UFix64, flowPayment: @FungibleToken.Vault) {
        pre {
            price > 0.0: "Price should be greater than zero"
            templateId != nil : "te,mplate id  must not be null"
            flowPayment.balance == price: "Your vault does not have balance to buy NFT"
            receiptAddress != nil : "receipt address must not be null"
        }
        let vaultRef = self.adminRef!.borrow()
            ?? panic("Could not borrow reference to owner token vault")
        vaultRef.deposit(from: <-flowPayment)
        var templateData = AFLNFT.getTemplateById(templateId:templateId)
            AFLNFT.mintNFT(templateId: templateId, account: receiptAddress)
        emit PackBought(templateId: templateId, receiptAddress: receiptAddress)
            
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
        var adminRefCap =  self.account.getCapability<&FlowToken.Vault{FungibleToken.Receiver}>(/public/flowTokenReceiver)
        self.adminRef = adminRefCap
        self.allPacks = {}

        self.PackStoragePath = /storage/AFLPack
        self.PackPublicPath = /public/AFLPack
        self.account.save(<- create Pack(), to: self.PackStoragePath)
        self.account.link<&{PackPublic}>(self.PackPublicPath, target: self.PackStoragePath)
    }
}