local class = require("third.class.NewClass")

local YaShiBenefit = {
    __skillActiveZhaoRelationMap = {},
    __activeZhaoInfoList = {},
    __skillTitleList = {},
    __canExchange = false
}

local YaShiActiveZhaoList = require("script.activity.Monthlycardysgift")["Sheet1"]
local GoodsHelper = require("app.models.Store.GoodsHelper")

function YaShiBenefit:create()
    return YaShiBenefit:new()
end

function YaShiBenefit:setCanExchange(isTrue)
    self.__canExchange = isTrue
end

function YaShiBenefit:getCanExchange()
    return self.__canExchange
end

function YaShiBenefit:setRole(role)
    self._role = role
end

function YaShiBenefit:initActiveZhaoInfoList()
    if MapIsEmpty(self.__activeZhaoInfoList) == true then
        for k, v in pairs(YaShiActiveZhaoList) do
            local goods = GoodsHelper:getGoodsResClass(v.goodsId)
            local itemAttr = Item:getOneItemByKey(goods:getItemId())

            if not itemAttr.zhaoId then
                error("当前商品不属于残页！！ goodsId："..tostring(v.goodsId))
            end

            if self._role:getSkillZhaoLv(itemAttr.zhaoId) > 0 and self._role:getSkillZhaoLv(itemAttr.zhaoId) < 10 then
                self.__activeZhaoInfoList[itemAttr.zhaoId] = {
                    id = v.giftId, 
                    activeZhaoId = itemAttr.zhaoId, 
                    goodsId = v.goodsId, 
                    price = v.moneyNumber
                }
            end
        end
    end

    return self.__activeZhaoInfoList
end

function YaShiBenefit:getActiveZhaoInfoBySkillId(skillId)
    local info = {}
    local zhaoList = self.__skillActiveZhaoRelationMap[skillId]
    if MapIsEmpty(zhaoList) == false then
        for i, zhaoId in ipairs(zhaoList) do
            local zhao = Skill:getActiveZhao(zhaoId)
            
            table.insert(info, {
                name = zhao:getName(),
                lv = self._role:getSkillZhaoLv(zhaoId),
                exp = Helper:mathFloor(self._role:getSkillZhaoExp(zhaoId)),
                maxExp = Helper:mathFloor(self._role:getZhaoExpLimit(zhaoId,self._role:getZhaoLvLimit(zhaoId))),
                price = self.__activeZhaoInfoList[zhaoId].price,
                goodsId = self.__activeZhaoInfoList[zhaoId].goodsId,
                id = self.__activeZhaoInfoList[zhaoId].id,
            })
        end
    end

    table.sort(info, function(a, b)
        return a.exp > b.exp
    end)

    return info
end

function YaShiBenefit:getSkillList()
    if MapIsEmpty(self.__skillTitleList) == false  then
        return self.__skillTitleList
    end

    self.__skillTitleList = {
        {name = "拳脚", list = {}},
        {name = "兵器", list = {}},
        {name = "轻功", list = {}},
        {name = "内功", list = {}},
        {name = "招架", list = {}},
    }

    --@desc 过滤不同招式属于同一个武学
    local filterMap = {}
    local familyNameList = {}
    local Family = require("app.models.family.Family")

    for activeZhaoId,zhaoInfo in pairs(self.__activeZhaoInfoList) do
        local skillId = Skill:getSkillIdByZhaoId(activeZhaoId)
        local skill = Skill:getSkill(skillId)

        if not self.__skillActiveZhaoRelationMap[skillId] then
            self.__skillActiveZhaoRelationMap[skillId] = {}
        end

        table.insert(self.__skillActiveZhaoRelationMap[skillId], activeZhaoId)

        if filterMap[skillId] ~= true and skill.methods then
            filterMap[skillId] = true

            local skillFamilyList = skill:getBelongFamily()
            local familyNameStr = ""
            for i = #skillFamilyList, 1, -1 do
                if familyNameList[skillFamilyList[i]] then
                    familyNameStr = familyNameStr .. familyNameList[skillFamilyList[i]]
                else
                    local family = Family:getFamily(skillFamilyList[i])
                    familyNameList[skillFamilyList[i]] = family:getName()
                    familyNameStr = familyNameStr .. familyNameList[skillFamilyList[i]]
                end

                if i ~= 1 then
                    familyNameStr = familyNameStr.."、"
                end
            end

            if familyNameStr ~= "" then
                familyNameStr = "("..familyNameStr..")"
            end

            local skillInfo = {id = skill.id, name = skill.name..familyNameStr}

            for i,vtype in ipairs(skill.methods) do
                if vtype == SKILL_METHOD_TYPE_QUANJIAO then
                    table.insert(self.__skillTitleList[1].list, skillInfo)
                elseif vtype == SKILL_METHOD_TYPE_NEIGONG then
                    table.insert(self.__skillTitleList[4].list, skillInfo)
                elseif vtype == SKILL_METHOD_TYPE_QINGGONG then
                    table.insert(self.__skillTitleList[3].list, skillInfo)
                elseif vtype == SKILL_METHOD_TYPE_ZHAOJIA and #skill.methods == 1 then
                    table.insert(self.__skillTitleList[5].list, skillInfo)
                elseif vtype == SKILL_METHOD_TYPE_JIAN or vtype == SKILL_METHOD_TYPE_DAO or vtype == SKILL_METHOD_TYPE_GUN or vtype == SKILL_METHOD_TYPE_ANQI or vtype == SKILL_METHOD_TYPE_BIANFA or vtype == SKILL_METHOD_TYPE_SHUANGCHI or vtype == SKILL_METHOD_TYPE_QIN then
                    local temp = false
                    for _,tempSkill in ipairs(self.__skillTitleList[2].list) do
                        if tempSkill.id == skill.id then
                            temp = true
                            break
                        end
                    end

                    if temp == false then
                        table.insert(self.__skillTitleList[2].list, skillInfo)
                    end
                end
            end
        end
    end

    for i, v in ipairs(self.__skillTitleList) do
        table.sort(v.list,function(a, b)
            local aZhaoInfo = self:getActiveZhaoInfoBySkillId(a.id)
            local aZhaoMaxExp = aZhaoInfo[1].exp

            local bZhaoInfo = self:getActiveZhaoInfoBySkillId(b.id)
            local bZhaoMaxExp = bZhaoInfo[1].exp

            if aZhaoMaxExp == bZhaoMaxExp then
                return a.id > b.id
            end
            
            return aZhaoMaxExp > bZhaoMaxExp
        end)
    end

    return self.__skillTitleList
end

function YaShiBenefit:getNingShenDanInfo()
    local goodsId = "400002" 
    local goods = GoodsHelper:getGoodsResClass(goodsId)
    local info = {
        goodsId = goodsId,
        dsc = goods:getDsc(),
        name = goods:getName(),
        number = 1,
        price = 5,
        max = math.floor(self._currencyCount/5),
        priceName = self:getCurrencyName()
    }

    return info
end

function YaShiBenefit:setCurrencyNum(num)
    self._currencyCount = num
end

function YaShiBenefit:getCurrencyNum()
    return self._currencyCount
end

function YaShiBenefit:getMaxCurrencyNum()
    return 1000
end

function YaShiBenefit:getCurrencyName()
    return "额度"
end

function YaShiBenefit:getYaShiTime()
    return self._yashiExpiredTime
end

--[[
    @desc: 
    author:tanqinjian
    time:2025-05-30 15:30:42
    --@id: type == 1时，为奖励id；type == 2时，为商品id
	--@num:
	--@type:1、残页 2、商品
	--@callback: 
    @return:
]]
function YaShiBenefit:exchange(id, num, type, callback)
    HttpManagerEx:exchangeYashiWelfareReward(id, num, type, self._role:getCurrencyVersion(), function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            self:setCurrencyNum(data.yashiWelfarePoint)
            self._yashiExpiredTime = data.yashiExpiredTime

            if type == 1 then
                local rewards = {}
                local rewardInfo = YaShiActiveZhaoList[id]
                table.insert(rewards, {id = rewardInfo.goodsId, num = num})

                local GrantGoodRequest = require("app.models.Store.GrantGoodRequest")
                GoodsHelper:fromNetworkGrantGoods(self._role,GrantGoodRequest:create({goodsList = rewards}))
            end

            if data.currencyVersion then
                self._role:setCurrencyVersion(data.currencyVersion)
            end
            
            local isTrue = false
            if self._currencyCount == 0 then
                isTrue = true
            end

            if callback then
                callback(isTrue, data.msg)
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

return class("YaShiBenefit", {}, YaShiBenefit)
00000000000000