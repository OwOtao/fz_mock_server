local zhishiSkillsParamsConf = requireWithEncrypt("script.zhishiSkills.zhishiSkillsParamsConf")["知识通用参数"]
local SkillConst = {
    -- @desc 技能类型
    SkillType = {
        -- @desc 普通技能
        NORMAL_SKILL = 1,
        -- @desc 周公之术
        ZHOU_GONG_ZHI_SHU = 2,
        -- 洗髓经
        XI_SUI_JING = 3,
        -- 洞元录
        DONG_YUAN_LU = 4
    },
    --@region  该类型不适用于旧版武学，仅适用于新版武学及自创武学

    SkillFirstType = {
        QUAN_JIAO = 1,
        BING_QI = 2,
        NEI_GONG = 3,
        QING_GONG = 4,
        ZHAO_JIA = 5
    },
    SkillThirdType = {
        QUAN_FA = 1001,
        ZHANG_FA = 1002,
        ZHUA_FA = 1003,
        ZHI_FA = 1004,
        TUI_FA = 1005,
        JIAN_FA = 2001,
        DAO_FA = 2002,
        FU_FA = 2008,
        GUN_FA = 2003,
        QIANG_FA = 2009,
        BIAN_FA = 2004,
        AN_QI = 2005,
        SHUANG_CHI = 2006,
        QIN_FA = 2007,
        QING_GONG = 3001,
        NEI_GONG = 4001,
        ZHAO_JIA = 5001
    }

    --@endregion
}

SkillConst.SkillSecondType = {
    QUAN_JIAO = 101,
    DAO_FA = 201,
    JIAN_FA = 202,
    GUN_FA = 203,
    BIAN_FA = 204,
    SHUANG_CHI = 205,
    AN_QI = 206,
    QIN_FA = 207,
    NEI_GONG = 301,
    QING_GONG = 401,
    ZHAO_JIA = 501
}

SkillConst.ZhiShiSkillParams = {
    TRANSFORM_STR_NEED = "strNeed",
    TRANSFORM_DEX_NEED = "dexNeed",
    TRANSFORM_CON_NEED = "conNeed",
    TRANSFORM_INT_NEED = "intNeed",
    TRANSFORM_MONEY = "transform_money",
    TRANSFORM_ITEM = "transform_item",
    TIPS_TRANSFORMFAIL = "tips_transformFail",
    DESC_SKILLUSE = "desc_skillUse",
    TIPS_TRANSFORM_ITEM_SUCCESS = "tips_transform_item_success",
    INFO_TRANSFORM_ITEM_SUCCESS = "info_transform_item_success",
    DESC_TRANSFORM_MONEY = "desc_transform_money",
    DESC_TRANSFORM_MONEYCOST = "desc_transform_moneyCost",
    TIPS_TRANSFORM_MONEY_SUCCESS = "tips_transform_money_success",
    INFO_TRANSFORM_MONEY_SUCCESS = "info_transform_money_success",
    INFO_TRANSFORM_SKILLDSC = "info_transform_skillDsc",
    UPGRADE_ROLE_POT_BASE = "upgrade_role_pot_base",
    UPGRADE_ROLE_POT_PARAM = "upgrade_role_pot_param",
    TIPS_UPGRADE_JINGLACK = "tips_upgrade_jingLack",
    TIPS_UPGRADE_POTLACK = "tips_upgrade_potLack",
    TIPS_UPGRADE_MORELACK = "tips_upgrade_MoreLack",
    INFO_UPGRADE_SUCCESSONE = "info_upgrade_successOne",
    INFO_UPGRADE_SUCCESSMORE = "info_upgrade_successMore",
    INFO_UPGRADE_SUCCESSLEVEL = "info_upgrade_successLevel",
    SKILLID_TRANSFORM = "skillID_transform",
    SKILLID_MERIDIAN = "skillID_meridian",
    MERIDIANCONVERT_STAGE = "meridianConvert_stage",
    MERIDIANCONVERT_USERESET = "meridianConvert_useReset",
    MERIDIANCONVERT_ITEMCOST = "meridianConvert_itemcost"
}

SkillConst.PrepareList = {
    quanjiao1 = "jibenquanjiao",
	quanjiao2 = "jibenquanjiao",
	neigong = "jibenneigong",
	qinggong = "jibenqinggong",
	zhaojia = "jibenzhaojia",
	jianfa = "jibenjianfa",
	daofa = "jibendaofa",
	gunfa = "jibengunfa",
	anqi = "jibenanqi",
	bianfa = "jibenbianfa",
	shuangchi = "jibenshuangchi",
	qinfa = "jibenqinfa",
}

local function getZhiShiSkillParamContent(zhiShiSkillParam)
    if MapIsEmpty(zhishiSkillsParamsConf) == false then
        for k,v in pairs(zhishiSkillsParamsConf) do
            if zhiShiSkillParam == v.id then
                return v.content
            end
        end
    end
end

SkillConst.SpecialGrowUpZhiShiSkillList = {
    "zhougongzhishu",
    getZhiShiSkillParamContent("skillID_transform"),
    getZhiShiSkillParamContent("skillID_meridian"),
    getZhiShiSkillParamContent("skillID_pointSwitch"),
}

function SkillConst:getZhiShiSkillParamContent(zhiShiSkillParam)
    return getZhiShiSkillParamContent(zhiShiSkillParam)
end

local PrepareSkillsAttrName = {
    QUANJIAO1 = "quanjiao1",
    QUANJIAO2 = "quanjiao2",
    ZHAOJIA = "zhaojia",
    NEIGONG = "neigong",
    QINGGONG = "qinggong",
    JIANFA = "jianfa",
    DAOFA = "daofa",
    ANQI = "anqi",
    BIANFA = "bianfa",
    GUNFA = "gunfa",
    SHUANGCHI = "shuangchi",
    QINFA = "qinfa",
}


function SkillConst:getWeaponSkillAttrNameList()
    return {
        PrepareSkillsAttrName.JIANFA,
        PrepareSkillsAttrName.DAOFA,
        PrepareSkillsAttrName.ANQI,
        PrepareSkillsAttrName.BIANFA,
        PrepareSkillsAttrName.GUNFA,
        PrepareSkillsAttrName.SHUANGCHI,
        PrepareSkillsAttrName.QINFA,
    }
end

function SkillConst:getWeaponItemType(skillAttrName)
    return switch(
        skillAttrName,
        {
            [PrepareSkillsAttrName.JIANFA] = Item.ITEM_TYPE.WEAPON_TYPE.JIAN,
            [PrepareSkillsAttrName.DAOFA] = Item.ITEM_TYPE.WEAPON_TYPE.DAO,
            [PrepareSkillsAttrName.ANQI] = Item.ITEM_TYPE.WEAPON_TYPE.ANQI,
            [PrepareSkillsAttrName.BIANFA] = Item.ITEM_TYPE.WEAPON_TYPE.BIAN,
            [PrepareSkillsAttrName.GUNFA] = Item.ITEM_TYPE.WEAPON_TYPE.GUN,
            [PrepareSkillsAttrName.SHUANGCHI] = Item.ITEM_TYPE.WEAPON_TYPE.SHUANGCHI,
            [PrepareSkillsAttrName.QINFA] = Item.ITEM_TYPE.WEAPON_TYPE.QIN
        }
    )
end

function SkillConst:getSkillTypeByPrepareType(skillAttrName)
    return switch(
        skillAttrName,
        {
            [PrepareSkillsAttrName.QUANJIAO1] = self.SkillFirstType.QUAN_JIAO,
            [PrepareSkillsAttrName.QUANJIAO2] = self.SkillFirstType.QUAN_JIAO,
            [PrepareSkillsAttrName.JIANFA] = self.SkillFirstType.BING_QI,
            [PrepareSkillsAttrName.DAOFA] = self.SkillFirstType.BING_QI,
            [PrepareSkillsAttrName.ANQI] = self.SkillFirstType.BING_QI,
            [PrepareSkillsAttrName.BIANFA] = self.SkillFirstType.BING_QI,
            [PrepareSkillsAttrName.GUNFA] = self.SkillFirstType.BING_QI,
            [PrepareSkillsAttrName.SHUANGCHI] = self.SkillFirstType.BING_QI,
            [PrepareSkillsAttrName.QINFA] = self.SkillFirstType.BING_QI,
            [PrepareSkillsAttrName.NEIGONG] = self.SkillFirstType.NEI_GONG,
            [PrepareSkillsAttrName.QINGGONG] = self.SkillFirstType.QING_GONG,
            [PrepareSkillsAttrName.ZHAOJIA] = self.SkillFirstType.ZHAO_JIA,
        }
    )
end

--@desc 获取兵器类武学
function SkillConst:getPrepareWeaponSkills(prepareSkills)
    local weaponSkillAttrName = {
        "jianfa",
        "daofa",
        "anqi",
        "bianfa",
        "gunfa",
        "shuangchi",
        "qinfa"
    }

    local prepareSkillsTb = {}

    if MapIsEmpty(prepareSkills) == false then
        for index, skillWeaponType in ipairs(self:getWeaponSkillAttrNameList()) do
            if prepareSkills[skillWeaponType] ~= nil then
               prepareSkillsTb[skillWeaponType] = prepareSkills[skillWeaponType]
            end
        end
    end

    return prepareSkillsTb
end

--@desc: 根据武学类型名称获取武学类型
--@author:LvBin
--@time:2024-07-15 18:14:20
--@typeName: 
--@return
function SkillConst:getSkillTypeByName(typeName)
    return switch(
        typeName,
        {
            ["拳脚"] = "quanjiao1",
            ["兵器"] = "bingqi",
            ["轻功"] = "qinggong",
            ["内功"] = "neigong",
            ["招架"] = "zhaojia",
            ["知识"] = "zhishi",
            ["default"] = "bingqi"
        }
    )
end

--@desc: 获取攻击武学准备位
--@author:LvBin
--@time:2026-04-24 16:32:24
--@return
function SkillConst:getAttackSkillPrepares()
	return {
		"quanjiao1",
		"quanjiao2",
		"jianfa",
        "daofa",
        "anqi",
        "bianfa",
        "gunfa",
        "shuangchi",
        "qinfa"
	}
end

return SkillConst
0