local NewClass = require("third.class.NewClass")
local AbstractUseItem = require("app.models.role.item.UseItem.AbstractRoleUseItem")
local SkillConst = require("app.models.skill.SkillConst")
local itemOfAttr = SkillConst:getZhiShiSkillParamContent(SkillConst.ZhiShiSkillParams.TRANSFORM_ITEM)
local str_need = SkillConst:getZhiShiSkillParamContent(SkillConst.ZhiShiSkillParams.TRANSFORM_STR_NEED)
local con_need = SkillConst:getZhiShiSkillParamContent(SkillConst.ZhiShiSkillParams.TRANSFORM_CON_NEED)
local dex_need = SkillConst:getZhiShiSkillParamContent(SkillConst.ZhiShiSkillParams.TRANSFORM_DEX_NEED)
local int_need = SkillConst:getZhiShiSkillParamContent(SkillConst.ZhiShiSkillParams.TRANSFORM_INT_NEED)
local attrPointLimit = {80, 110, 150, 200, 250, 300} --先天属性点总上限

itemOfAttr = json.decode(itemOfAttr)

local ItemCondition = {
    ["int"] = int_need,
    ["str"] = str_need,
    ["dex"] = dex_need,
    ["con"] = con_need
}

local RoleUseItem_XiSuiDan = {}

function RoleUseItem_XiSuiDan:__canUseItem()
    local item = self._item
    local itemId = item.id
    local role = self._role

    local itemInfo = self:__getItemConfig()
    self.__attrType = itemInfo[1]
    self.__attrBaseRemoveNum = itemInfo[2]

    local attr = self.__attrType
    local attrRemoveNum = self.__attrBaseRemoveNum
    local attrUseCondition = ItemCondition[attr]
    local attrName = role:getCHAttrName(attr)

    if role:getAttr(attr) < attrUseCondition then
        local str = SkillConst:getZhiShiSkillParamContent(SkillConst.ZhiShiSkillParams.TIPS_TRANSFORMFAIL)
        str = string.gsub(str, "$(%w+)", {attrN = role:getCHAttrName(attr), needArrt = attrUseCondition})
        self:__popText(str)
        return
    end

    return true
end

function RoleUseItem_XiSuiDan:__doUseItem()
    local item = self._item
    local itemId = item.id
    local role = self._role

    local attr = self.__attrType
    local attrRemoveNum = self.__attrBaseRemoveNum
    local attrName = role:getCHAttrName(attr)

    local xisuijing = role:getSkillExp(SkillConst:getZhiShiSkillParamContent(SkillConst.ZhiShiSkillParams.SKILLID_TRANSFORM))

    local skill = Skill:getSkill(SkillConst:getZhiShiSkillParamContent(SkillConst.ZhiShiSkillParams.SKILLID_TRANSFORM))

    local skillAdd = skill:getAttrPointValue(attr, xisuijing)

    attrRemoveNum = attrRemoveNum + skillAdd

    local itemNum = 1
    local skillDsc, extraDesc = "", ""

    if skillAdd > 0 then
        extraDesc = SkillConst:getZhiShiSkillParamContent(SkillConst.ZhiShiSkillParams.DESC_SKILLUSE)
        extraDesc = string.gsub(extraDesc, "$(%w+)", {attrN = attrName, tranS = skillAdd})
        skillDsc = SkillConst:getZhiShiSkillParamContent(SkillConst.ZhiShiSkillParams.INFO_TRANSFORM_SKILLDSC)
        skillDsc = string.gsub(skillDsc, "$(%w+)", {skillN = skill:getName(), tranS = skillAdd})
    end

    self:__initBefRecords()

    role._iOutput:showUseXiSuiDanConfirm(
        item,
        extraDesc,
        function()
            HttpManagerEx:checkItemIsCanUse(
                itemId,
                itemNum,
                function(status, errcode, errmsg, data)
                    if status == 200 then
                        if errcode == 0 then
                            role:addItemCount(itemId, -1)

                            local NaturalAttrUtil = require("app.models.role.attr.NaturalAttributePlan.NaturalAttrUtil")
                            local naturalAttrAdjustmentPlan = NaturalAttrUtil:getPlayerCurrentNaturalAdjustmentPlan()
                            local plan = naturalAttrAdjustmentPlan:getUsagePlan()
                            plan:setNaturalPlanAttr(attr, plan:getNaturalPlanAttr(attr) - attrRemoveNum)
                            naturalAttrAdjustmentPlan:useAttrAdjustmentPlanType(plan:getNaturalPlanType())

                            self:__initAftRecords()

                            local desc1 = SkillConst:getZhiShiSkillParamContent(SkillConst.ZhiShiSkillParams.TIPS_TRANSFORM_ITEM_SUCCESS)
                            desc1 = string.gsub(desc1, "$(%w+)", {attrN = attrName, tran = attrRemoveNum})
                            local desc2 = SkillConst:getZhiShiSkillParamContent(SkillConst.ZhiShiSkillParams.INFO_TRANSFORM_ITEM_SUCCESS)
                            desc2 = string.gsub(desc2, "$(%w+)", {itemN = item.name, tranA = attrRemoveNum, attrN = attrName, skillDsc = skillDsc})

                            self:__popText(desc1)
                            self:__richPrint(desc2)
                            self:__onUseAft()

                            self:__record()
                        else
                            self:__popText("丹药未通过正品检测，请购买正品")
                            return
                        end
                    else
                        self:__popText(errmsg)
                    end
                end,
                IS_SHOW_WAITING
            )
        end,
        function()
        end
    )

    return true
end

function RoleUseItem_XiSuiDan:__getItemConfig()
    local item = self._item
    local itemId = item.id

    for _itemId, itemConfig in pairs(itemOfAttr) do
        if itemId == _itemId then
            return itemConfig
        end
    end
end

function RoleUseItem_XiSuiDan:__initBefRecords()
    local records = {}
    local item = self._item
    local itemId = item.id

    local befCount = self._role:getItemTotalCount(itemId)
    local befStr = self._role:getAttr("str")
    local befCon = self._role:getAttr("con")
    local befInt = self._role:getAttr("int")
    local befDex = self._role:getAttr("dex")
    local inheritCount = self._role:getAttr("inheritCount")
    local befFreePoint = attrPointLimit[inheritCount + 1] - befStr - befDex - befCon - befInt

    self.__befRecord = {
        befCount = befCount,
        befStr = befStr,
        befInt = befInt,
        befCon = befCon,
        befDex = befDex,
        befFreePoint = befFreePoint
    }
end

function RoleUseItem_XiSuiDan:__initAftRecords()
    local records = {}
    local item = self._item
    local itemId = item.id

    local aftCount = self._role:getItemTotalCount(itemId)
    local aftStr = self._role:getAttr("str")
    local aftCon = self._role:getAttr("con")
    local aftInt = self._role:getAttr("int")
    local aftDex = self._role:getAttr("dex")
    local inheritCount = self._role:getAttr("inheritCount")
    local aftFreePoint = attrPointLimit[inheritCount + 1] - aftStr - aftDex - aftCon - aftInt

    self.__aftRecord = {
        aftCount = aftCount,
        aftStr = aftStr,
        aftInt = aftInt,
        aftCon = aftCon,
        aftDex = aftDex,
        aftFreePoint = aftFreePoint
    }
end

function RoleUseItem_XiSuiDan:__record()
    local records = {}
    records.method = {
        itemId = self._item.id,
        befCount = self.__befRecord.befCount,
        aftCount = self.__aftRecord.aftCount
    }
    records.beforeAttr = {
        str = self.__befRecord.befStr,
        int = self.__befRecord.befInt,
        con = self.__befRecord.befCon,
        dex = self.__befRecord.befDex,
        free = self.__befRecord.befFreePoint
    }

    records.afterAttr = {
        str = self.__aftRecord.aftStr,
        int = self.__aftRecord.aftInt,
        con = self.__aftRecord.aftCon,
        dex = self.__aftRecord.aftDex,
        free = self.__aftRecord.aftFreePoint
    }

    local skillId = SkillConst:getZhiShiSkillParamContent(SkillConst.ZhiShiSkillParams.SKILLID_TRANSFORM)
    local skillExp = self._role:getSkillExp(skillId)
    local skill = Skill:getSkill(skillId)
    local skillAdd = skill:getAttrPointValue(self.__attrType, skillExp)
    records.skillExp = skillExp
    records.skillLv = self._role:getSpecialZhiShiSkillLv(skillId)
    records.basePoint = self.__attrBaseRemoveNum
    records.skillAddPoint = skillAdd
    records.finalPoint = self.__attrBaseRemoveNum + skillAdd

    HttpManagerEx:uploadWashAttributeRecord(
        records,
        function(status, errcode, errmsg, data)
        end,
        IS_SHOW_WAITING
    )
end

return NewClass("RoleUseItem_XiSuiDan", {AbstractUseItem}, RoleUseItem_XiSuiDan)
00