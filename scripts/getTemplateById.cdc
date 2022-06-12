
import AFLNFT from 0x4ea480b0fc738e55
pub fun main(templateId:UInt64): AFLNFT.Template {
    return AFLNFT.getTemplateById(templateId:templateId)
}