import AFLNFT from 0xf33e541cb9446d81

pub fun main(nftId: UInt64):AFLNFT.NFTData{
    return AFLNFT.getNFTData(nftId: nftId)
}