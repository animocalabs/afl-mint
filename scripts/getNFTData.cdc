import AFLNFT from 0x01cf0e2f2f715450

pub fun main():AFLNFT.NFTData{
    return AFLNFT.getNFTData(nftId:2)
}