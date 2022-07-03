
import AFLNFT from 0xf33e541cb9446d81
pub fun main(templateId:UInt64): AFLNFT.Template {
    return AFLNFT.getTemplateById(templateId:templateId)
}