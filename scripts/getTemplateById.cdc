
import AFLNFT from 0x01cf0e2f2f715450
pub fun main(templateId:UInt64): AFLNFT.Template {
    return AFLNFT.getTemplateById(templateId:templateId)
}