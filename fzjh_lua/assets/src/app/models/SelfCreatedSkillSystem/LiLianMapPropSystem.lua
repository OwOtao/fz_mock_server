local NewClass = require("third.class.NewClass")
local ISelfCreatedSkillPropSystem = require("app.models.SelfCreatedSkillSystem.ISelfCreatedSkillPropSystem")
local SelfCreatedSkillManager = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillManager.SelfCreatedSkillManager")
local SelfCreatedSkillConstants = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillConstants")

local LiLianMapPropSystem = {
    __propList = {
        -- {
        --     propId = "glczwanquanchongzhi001",
        --     count = 10
        -- },
    }
}

function LiLianMapPropSystem:create()
    return LiLianMapPropSystem.new()
end

function LiLianMapPropSystem:setRole(role)
    self.__role = role
end

function LiLianMapPropSystem:getRole()
    return self.__role
end

--@desc 获取道具列表
--@propType:  1创作道具   2改良道具
function LiLianMapPropSystem:getPropList(propType,callback)
    if propType == 2 then
        if callback then
            callback(self.__propList)
        end
    else
        print("道具类型有误 propType = ",propType)
    end
end

--@desc 使用创作道具
function LiLianMapPropSystem:useCreateProp(propId,userLv,skillDataId,callback)
end

--@desc 使用改良道具
function LiLianMapPropSystem:useImproveProp(propId,userLv,zhaoIndex,skillDataId,callback)
    local propData = SelfCreatedSkillManager:getPropMap(propId)
    if not propData then
        print("LiLianMapPropSystem:useImproveProp       propId = ",propId)
        return
    end
    switch(propData.functionType,{
        [SelfCreatedSkillConstants.PropType.ZHAO_ALL_RESET] = function()
            local selfCreatedSkillSystem = self:getRole():getSelfCreatedSkillSystem()
            local oldZhao = selfCreatedSkillSystem:getZhaoBySkillDataId(skillDataId,zhaoIndex)

            if propData.needZhaoQuality == 0 or oldZhao:getQuality() == propData.needZhaoQuality then
                local lilianZhaoArray = SelfCreatedSkillManager:getLiLianZhaoArray()
                local newZhaoTemplateId = lilianZhaoArray[math.random(1,#lilianZhaoArray)].id

                local affixNum = 0
                print("oldZhao:getQuality() = ",oldZhao:getQuality())
                if oldZhao:getQuality() == SelfCreatedSkillConstants.ZhaoQuality.Delicate then
                    affixNum = math.random(0,1)
                elseif oldZhao:getQuality() == SelfCreatedSkillConstants.ZhaoQuality.Extraordinary then
                    affixNum = math.random(1,2)
                elseif oldZhao:getQuality() == SelfCreatedSkillConstants.ZhaoQuality.Supernatural then
                    affixNum = math.random(2,3)
                end

                local atkAffixs = {}
                local defAffixs = {}
                local affixArray = {}
                
                if affixNum > 0 then
                    local liLianAffaixArray = SelfCreatedSkillManager:getLiLianRandomAffaixArray()
                    for i = 1,affixNum do
                        table.insert(affixArray,liLianAffaixArray[math.random(1,#liLianAffaixArray)] ) 
                    end

                    for i,affixMap in ipairs(affixArray) do
                        local affixData = {
                            effectId = affixMap.affixId,
                            value1 = affixMap.effect1,
                            value2 = affixMap.effect2,
                            value3 = affixMap.effect3,
                            needLv = affixMap.needLv
                        }

                        if i <= 3 then
                            table.insert(atkAffixs,affixData)
                        else
                            table.insert(defAffixs,affixData)
                        end
                    end
                end

                local zhaoData = {
                    index = oldZhao:getIndex(),
                    name = oldZhao:getName(),
                    colorId = oldZhao:getColorId(),
                    dscId = oldZhao:getDscId(),
                    quality = oldZhao:getQuality(),
                    useType = oldZhao:getUseType(),
                    templateId = newZhaoTemplateId,
                    atkAffixs = atkAffixs,
                    defAffixs = defAffixs
                }

                if self:addProp(propId,-1) == true then
                    local createdSkillData = selfCreatedSkillSystem:getCreatedSkillData()
                    if createdSkillData[skillDataId] and createdSkillData[skillDataId].zhaos[zhaoIndex] then
                        createdSkillData[skillDataId].zhaos[zhaoIndex] = zhaoData
                        selfCreatedSkillSystem:updataSelfCreatedSkillMap()
                        
                        if callback then
                            callback({zhaos = zhaoData})
                        end
                    end
                else
                    PopText("使用的道具不存在")
                end
            else
                PopText("你的招式品质不符合使用条件。")
            end 
        end
    })


end

--@desc 添加道具
function LiLianMapPropSystem:addProp(propId,count)
    if propId == nil or count == nil or count == 0 then
        return false
    end

    local isHave = false
    local index
    for i,v in ipairs(self.__propList) do
        if v.propId == propId then
            isHave = true
            index = i
        end
    end
    if isHave == false then
        if count > 0 then
            table.insert(self.__propList,{propId = propId,count = count})
            return true
        else
            return false
        end
    else
        if count > 0 then
            self.__propList[index].count = self.__propList[index].count + count
            return true
        else
            self.__propList[index].count = self.__propList[index].count + count
            if self.__propList[index].count <= 0 then
                table.remove(self.__propList,index)
            end
            return true
        end
    end
end

return NewClass("LiLianMapPropSystem", { ISelfCreatedSkillPropSystem }, LiLianMapPropSystem)000