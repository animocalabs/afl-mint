
import AFLNFT from 0xa33d4223b3818e3f
pub fun main(templateId:UInt64): AFLNFT.Template {
    return AFLNFT.getTemplateById(templateId:templateId)
}