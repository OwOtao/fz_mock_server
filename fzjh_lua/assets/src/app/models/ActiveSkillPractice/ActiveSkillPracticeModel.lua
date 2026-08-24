local NewClass = require("third.class.NewClass")

local HomelandRoleUtil = require("app.models.HomelandModel.HomelandRoleUtil")

local ActiveSkillPracticeModel = {}

local PraType = {
    Normal = 1, --普通对练
    Fast = 2    --加速对练
}

function ActiveSkillPracticeModel:create()
    local p = ActiveSkillPracticeModel.new()
    return p
end

function ActiveSkillPracticeModel:setPlayer(player)
    self.__role = player
end

function ActiveSkillPracticeModel:setNpc(npc)
    self.__npc = npc
end

function ActiveSkillPracticeModel:getResTrainServant()
    local trainServant = require("script.others.trainServant")["Sheet1"]
    return trainServant
end

function ActiveSkillPracticeModel:getHomeServantConf(id)
    local homeServant = require("script.others.homeServant")["Sheet1"]

    if homeServant[tostring(id)] == nil then
        error("  ActiveSkillPracticeModel:getHomeServantConf  参数找不到 id = "..id)
    end
    
    return homeServant[tostring(id)].content
end

function ActiveSkillPracticeModel:getFidelityLv()
    local zcLv = HomelandRoleUtil:getFidelityLv(self.__npc.defaultZhongCheng)

    return zcLv
end

function ActiveSkillPracticeModel:getZhaoIdList()
    return Helper:getDef(self.__npc.extra.zhaoIdList,{})
end

function ActiveSkillPracticeModel:getZhaoLearnNum()
    return Helper:getDef(self.__npc.extra.zhaoLearnNum,0) 
end

function ActiveSkillPracticeModel:getNpcName()
    return self.__npc.name
end

--@desc: 获取招式对练详情
--@author:LvBin
--@time:2022-11-07 18:24:14
--@npcId: 对练的npcId
--@callback:
--@return
function ActiveSkillPracticeModel:getZhaoPracticeInfo(npcId , callback)
    HttpManagerEx:getZhaoPracticeInfo(
        npcId,
        self.__role:getHouseId(),self.__role:getCurrencyVersion(),
        function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                callback(true,"",data)
            else
                callback(false,errmsg,data)
            end
        end,
        IS_SHOW_WAITING
    )
end

--@desc: 对练
--@author:LvBin
--@time:2022-11-07 18:25:24
--@zhaoId: 对练招式id
--@addExp: 对练增加经验值
--@costJing: 对练消耗精力值
--@type: 对练类型，1.普通对练 2.加速对练
--@callback:
--@return
function ActiveSkillPracticeModel:zhaoPractice(zhaoId , addExp, costJing, type, price, callback)
    HttpManagerEx:zhaoPractice(
        self.__npc.id,
        self.__role:getHouseId(),
        zhaoId,
        type,
        price,
        self.__role:getCurrencyVersion(),
        function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                self.__role:addSkillZhaoExp(zhaoId, addExp)

                self.__role:addAttr("jing",-costJing)

                if data.currencyVersion then
                    self.__role:setCurrencyVersion(data.currencyVersion)
                end

                callback(true, "", data)
            else
                callback(false, errmsg, data)
            end
        end,
        IS_SHOW_WAITING
    )
end

--@desc: 赠与残页
--@author:LvBin
--@time:2022-11-07 18:25:56
--@zhaoId: 残页对应的招式id
--@itemId: 残页的物品id
--@callback:
--@return
function ActiveSkillPracticeModel:giftZhaoPage(zhaoId, itemId, callback)
    HttpManagerEx:giftZhaoPage(
        self.__npc.id,
        self.__role:getHouseId(),
        zhaoId,
        function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                if MapIsEmpty(self.__npc.extra.zhaoIdList) then
                    self.__npc.extra.zhaoIdList = {}
                end

                table.insert(self.__npc.extra.zhaoIdList,zhaoId)

                if self.__npc.extra.zhaoLearnNum == nil then
                    self.__npc.extra.zhaoLearnNum = 0
                end

                self.__npc.extra.zhaoLearnNum = self.__npc.extra.zhaoLearnNum + 1

                self.__role:addZhaoShuXiang(itemId, - 1)
                
                callback(true, "", data)
            else
                callback(false, errmsg, data)
            end
        end,
        IS_SHOW_WAITING
    )
end

--@desc: 遗忘残页
--@author:LvBin
--@time:2022-11-07 18:27:23
--@zhaoId: 残页对应的招式id
--@callback:
--@return
function ActiveSkillPracticeModel:forgetZhaoPage(zhaoId, callback)
    HttpManagerEx:forgetZhaoPage(
        self.__npc.id,
        self.__role:getHouseId(),
        zhaoId,
        function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                if MapIsEmpty(self.__npc.extra.zhaoIdList) then
                    self.__npc.extra.zhaoIdList = {}
                end

                for i,v in ipairs(self.__npc.extra.zhaoIdList) do
                    if zhaoId == v then
                        table.remove(self.__npc.extra.zhaoIdList,i)
                        break
                    end    
                end 

                if self.__npc.extra.zhaoLearnNum == nil then
                    self.__npc.extra.zhaoLearnNum = 0
                end

                self.__npc.extra.zhaoLearnNum = self.__npc.extra.zhaoLearnNum - 1

                User:setRoleAttr("yuanbao", data.yuanbao_num)

                callback(true, "", data)
            else
                callback(false, errmsg, data)
            end
        end,
        IS_SHOW_WAITING
    )
end

function ActiveSkillPracticeModel:getSkillZhaos(skillId)
    local retZhaos = {}

    local zhaos = self.__role:getSkillZhaoList(skillId)
    
    for i,zhao in ipairs(zhaos) do
        if self:__cheakHaveZhaoId(zhao:getId()) then
            table.insert(retZhaos, zhao)
        end
    end
    return retZhaos
end

function ActiveSkillPracticeModel:__cheakHaveZhaoId(zhaoId)
    for i,v in ipairs(self:getZhaoIdList()) do
        if zhaoId == v then
            return true
        end    
    end 

    return false
end

function ActiveSkillPracticeModel:calCostJing(zhao)
    local praResMap = self:getPraResMap()

    local m = self.__role:getSkillZhaoPotEfficiency(zhao:getId())

    local zhaoExp = self.__role:getSkillZhaoExp(zhao:getId())

    local zhaoFactor = Helper:mathFloor(math.min((zhaoExp / 10 * m * 500 / 0.15)^(1/3)/100, self.__role:getZhaoLvLimit(zhao:getId())))

    local jingSave = praResMap.jingSave

    local jingSaveRatio = (100 - jingSave)/100

    local costJing = math.min(250 / m * (zhaoFactor + 2) + 10, 120) * jingSaveRatio

    print("陪练精力消耗costJing = math.min(250 / m * (zhaoFactor + 2) + 10, 120) * jingSaveRatio公式: ")
    print("参数m:", m, "参数主动重数对练系数：",zhaoFactor,"参数jingSaveRatio：",jingSaveRatio)

    return Helper:mathFloor(costJing)
end

function ActiveSkillPracticeModel:calAddExp(zhao,praType)
    local praResMap = self:getPraResMap()

    local m = self.__role:getSkillZhaoPotEfficiency(zhao:getId())

    local int = self.__role:getFinalAttr("int")

    local zhaoExp = self.__role:getSkillZhaoExp(zhao:getId())

    local zhaoFactor = Helper:mathFloor(math.min((zhaoExp / 10 * m * 500 / 0.15)^(1/3)/100, self.__role:getZhaoLvLimit(zhao:getId())))

    local baseproficiencyAdd = praResMap.baseproficiencyAdd

    local addRatio = (100 + baseproficiencyAdd)/100

    if praType == PraType.Fast then
        addRatio = (100 + baseproficiencyAdd + praResMap.proficiencyAdd)/100
    end

    local addExp = ((zhaoFactor + 2) * m / 10 + int / 10 + 5) * addRatio
    print("陪练招式经验增加addExp = ((zhaoFactor + 2) * m / 10 + int / 10 + 5) * addRatio公式参数：")
    print("参数m:", m, "参数主动重数对练系数：",zhaoFactor, "参数int：", int,"参数addRatio：",addRatio)

    return Helper:mathFloor(addExp)
end

--@desc: 加速对练消耗加速资源数量
function ActiveSkillPracticeModel:calCostNingShenDan(skillId, zhaoId)
    local skill = Skill:getSkill(skillId)

    local m = self.__role:getSkillZhaoPotEfficiency(zhaoId)

    local zhaoExp = self.__role:getSkillZhaoExp(zhaoId)

    local zhaoFactor = (zhaoExp / 10 * m * 500 / 0.15)^(1/3)/100

    zhaoFactor = math.min(self.__role:getZhaoLvLimit(zhaoId), zhaoFactor)

    local skillLearnPotEfficiency = skill:getLearnPotEfficiency()

    print("加速对练消耗加速资源数量 = math.ceil(86.96 / skill:getLearnPotEfficiency() * (zhaoFactor + 2) + 7)公式参数：")
    print("主动重数对练加速系数:",zhaoFactor, "武学.potEfficiency：", skillLearnPotEfficiency)

    return math.ceil(86.96 / skillLearnPotEfficiency * (zhaoFactor + 2) + 7)
end

function ActiveSkillPracticeModel:getPraResMap()
    local zcLv = self:getFidelityLv()
    
    local trainServant = self:getResTrainServant()
    
    for k,v in pairs(trainServant) do
        if zcLv == v.levelId then
            return v
        end
    end

    assert(false,"ActiveSkillPracticeModel:getPraResMap 忠诚度等级 :"..zcLv.."无资源配置！")
end

return NewClass("ActiveSkillPracticeModel", {}, ActiveSkillPracticeModel)0000000000000000