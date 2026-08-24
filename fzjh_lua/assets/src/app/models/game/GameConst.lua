local gameConstConfigs = require("res.script.others.gameConst")["Sheet1"]
local GameConst = {}

local defaultList = {
    seclusion_family_id = "seclusion",
    seclusion_family_name = "归隐",
    seclusion_family_touxian = "山林逸客",
    departFromFamilyTask_start_text = "需要达成以下条件后，调查江湖轶闻里的【祸乱云谷】事件，是否愿意前往？",
    departFromFamily_confirm_text = "是否决定离开师门？离开后师门个人功绩，贡献昌盛度，门派心法，建筑材料，资历、师门贡献度、师门声望值，师门排行榜等内容都会被清除。",
    departFromFamily_confirm_tips = "注意：离开师门时不能处于练功中和师门日常进行中，请终止后再次尝试",
    bafangyouli_dengmenxiebao = "weekdmxb",
	bafangyouli_xiazongzhiyuan = "weekhztc",
    bafangyouli_wujianhuiwu = "weekwjhl",
    teacherGuidance_dsc = "每天师门会派出长老对你进行指点，指点的次数与效果与你的师门名衔有关。"
}

function GameConst:getConfigValue(key)
    if not gameConstConfigs[key] then
        error("通用参数未找到配置 id：" .. key)
    end
    return gameConstConfigs[key].content
end

function GameConst:getDefaultValue(key)
    if not defaultList[key] then
        error("默认参数列表中未找到配置 id：" .. key)
    end
    return defaultList[key]
end


return GameConst000000