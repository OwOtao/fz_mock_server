local inherit = require("third.inherit.inherit")
local IDreamTalentPresenterOutput = require("app.presenters.dream.talent.IDreamTalentPresenterOutput")
local IDreamTalentPresenterInput = require("app.presenters.dream.talent.IDreamTalentPresenterInput")
local DreamTalentModel = require("app.models.DreamWorldModel.DreamTalentModel")
local isImplement = require("third.assertIsInstance.assertIsInstance")
local DreamConst = require("app.models.DreamWorldModel.DreamConst")
local OPERTION_EVENT_NAME = DreamConst.OpertionEventName

local DeamTalentPresenter = {}

function DeamTalentPresenter:create(iDreamTalentOutput, deamTalentModel)
    local p = inherit({}, DeamTalentPresenter)
    p:init(iDreamTalentOutput, deamTalentModel)
    return p
end

function DeamTalentPresenter:init(iDreamTalentOutput, deamTalentModel)
    self._iDreamTalentOutput = isImplement(iDreamTalentOutput, IDreamTalentPresenterOutput)
    self._deamTalentModel = isImplement(deamTalentModel, DreamTalentModel)
end

function DeamTalentPresenter:showDescText()
    local lv = self._deamTalentModel:getZhouGongZhiShuLv()

    self._iDreamTalentOutput:setLvText("周公之术:"..lv.."级")
    self._iDreamTalentOutput:setDescText("风天行：少侠，又见面了。在我这里所学，每次入梦你都会铭记在心，但于现世中却不能忆起分毫，切记！")
end

function DeamTalentPresenter:showDreamCoinsText()
    local currCoins = self._deamTalentModel:getCurrDreamCoins()

    self._iDreamTalentOutput:setDreamCoinsText("梦境币:"..currCoins)
end

function DeamTalentPresenter:showLayer()
    self._deamTalentModel:getWebTalentData(function(data)
        self:showDreamCoinsText()
        self:showDescText()
        self:initListView()
        
        self._iDreamTalentOutput:setShowLayer()
    end)
end

function DeamTalentPresenter:initListView()
    local talentList = {}
    local talentGroup = self._deamTalentModel:getTalentGroup()
    local dreamTalent = self._deamTalentModel:getDreamTalent()
    local prepareTalent = self._deamTalentModel:getPrepareTalent()

    --@desc 初始化要展示的天赋列表
    for groupId ,group in pairs(talentGroup) do
        local defaultTalent = self._deamTalentModel:getDefaultTalent(groupId)
        for i,talen in ipairs(group) do
            if talen.tfleveLs > defaultTalent.tfleveLs and self._deamTalentModel:checkTalentIdIsEmpty(dreamTalent,talen.id) == true then
                defaultTalent = talen
            end
        end
        table.insert(talentList, defaultTalent)
    end
    
    --[[
        排序
        1. 准备的天赋技能置顶
        2. 会的天赋技能
        3. 会的被动技能
        4. 已解锁未掌握的天赋技能
        5. 已解锁未掌握的被动技能
        6. 未解锁的天赋技能
        7. 未解锁的被动技能 
        8.同情况根据“天赋id”从低到高排序
    ]]
    table.sort(talentList, function(talent,talent2)
        local id = talent.id
        local id2 = talent2.id
        local exp = talent.drtfexp
        local exp2 = talent2.drtfexp
        local isPrepare = self._deamTalentModel:checkTalentIdIsEmpty(prepareTalent,id)
        local isPrepare2 = self._deamTalentModel:checkTalentIdIsEmpty(prepareTalent,id2)
        local isUnlock = self._deamTalentModel:checkTalentIdIsEmpty(dreamTalent,id)
        local isUnlock2 = self._deamTalentModel:checkTalentIdIsEmpty(dreamTalent,id2)
        if isPrepare and not isPrepare2 then
            return true
        elseif isPrepare and isPrepare2 then
            return id < id2
        elseif not isPrepare and isPrepare2 then
            return false
        elseif not isPrepare and not isPrepare2 then
            if isUnlock and not isUnlock2 then
                return true
            elseif isUnlock and isUnlock2 then
                if talent.drtfuse ~= talent2.drtfuse then
                    return talent.drtfuse > talent2.drtfuse
                else
                    return id < id2
                end
            elseif not isUnlock and isUnlock2 then
                return false
            elseif not isUnlock and not isUnlock2 then
                local zgzsExp = self._deamTalentModel:getZhouGongZhiShuExp()

                if zgzsExp >= exp and zgzsExp >= exp2 then
                    if talent.drtfuse ~= talent2.drtfuse then
                        return talent.drtfuse > talent2.drtfuse
                    else
                        return id < id2
                    end
                else
                    if exp == exp2 then
                        return id < id2
                    else
                        return exp < exp2
                    end
                end
            end
        end
    end)

    local retData = self:convertData(talentList)

    self._iDreamTalentOutput:setListView(retData)
end

function DeamTalentPresenter:convertData(talentList)
    local retdata = {}
    
    local prepareTalent = self._deamTalentModel:getPrepareTalent()
    local dreamTalent = self._deamTalentModel:getDreamTalent()

    for i = 1,#talentList do
        local retList = {
            name = "天赋技能",
            nameColor = {r = 255, g = 255, b = 255},
            dianVisible = false,
            hongdianVisible = false,
            buttonFunc = EMPTY_FUNC
        }

        local talent = talentList[i]
        local talentId = talent.id
        local talentType = talent.drtfuse

        retList["hongdianVisible"] = false

        --判断是否准备
        if self._deamTalentModel:checkTalentIdIsEmpty(prepareTalent,talentId) == true then
            retList["dianVisible"] = true
        else
            retList["dianVisible"] = false
        end
        
        if self._deamTalentModel:checkTalentIdIsEmpty(dreamTalent,talentId) == true then --已经掌握
            retList["name"] = talent.drtfname

            if talentType == 1 then
                retList["nameColor"] = {r = 209, g = 190, b = 74}
            else
                retList["nameColor"] = {r = 208, g = 206, b = 207}
            end

            --@desc 能否升级
            local canUpgrade = self._deamTalentModel:checkCanUpgrade(talentId)
            if canUpgrade == true then
                --@desc 当前是否是最高级
                if self._deamTalentModel:checkLevelIsMax(talentId) == true then
                    retList["buttonFunc"] = function()
                        self:showTalentInfo(talent,"升级",function()
                            self._iDreamTalentOutput:popText("当前等级为目前最高等级")
                        end,talent.drlvtext)
                    end
                else
                    local groupId = talent.tfgroupid
                    local groupList = self._deamTalentModel:getTalentGroupById(groupId)
                    local currLevel = talent.tfleveLs
                    local nextLevel = currLevel + 1
                    local nextTalentId = nil
                    if MapIsEmpty(groupList) then
                        assert(false,"天赋组为空  groupId = "..groupId)
                    end
                    for i,v in ipairs(groupList) do
                        if v.tfleveLs == nextLevel then
                            nextTalentId = v.id
                            break
                        end
                    end

                    if nextTalentId == nil then
                        assert(false,"天赋组没有下一个品级天赋  nextLevel = "..nextLevel.."groupId = "..groupId)
                    end
                    local nextTalent = self._deamTalentModel:getTalentAttrById(nextTalentId)
                    local zgzsExp = self._deamTalentModel:getZhouGongZhiShuExp()
                    if zgzsExp < nextTalent.drtfexp then
                        retList["buttonFunc"] = function()
                            self:showTalentInfo(talent,"升级",function()
                                self._iDreamTalentOutput:popText("经验不够，无法升级")
                            end,talent.drlvtext)
                        end
                    else
                        retList["hongdianVisible"] = true
                        retList["buttonFunc"] = function()
                            self:showTalentInfo(talent,"升级",function()
                                local text = "升级"..self:clearColorStr(talent.drtfname).."需要"..nextTalent.drtfmoney.."梦境币，是否升级？"
                                self._iDreamTalentOutput:setShowConfirmLayer(text,function()
                                    self._deamTalentModel:upgradeTalent(talentId,function(isSuccess,errmsg)
                                        if isSuccess == true then
                                            self._iDreamTalentOutput:popText("升级成功")
                                            self._iDreamTalentOutput:popText("梦境币-"..tostring(nextTalent.drtfmoney))
                                            self:showDreamCoinsText()
                                            self:initListView()
                                        else
                                            self._iDreamTalentOutput:popText(errmsg)
                                        end
                                    end)
                                end)
                            end,talent.drlvtext)
                        end
                    end
                end
            else
                retList["buttonFunc"] =function()
                    self:showTalentInfo(talent,nil,function()
                    end,talent.drlvtext)
                end
            end 
        else
            local needExp = talent.drtfexp --所需经验值
            local zgzsExp = self._deamTalentModel:getZhouGongZhiShuExp()

            if zgzsExp < needExp then
                retList["name"] = "？？？"
                retList["nameColor"] = {r = 208, g = 206, b = 207}
                retList["buttonFunc"] = function()
                    self._iDreamTalentOutput:popText("经验不够，未学习")
                end
            else
                retList["name"] = talent.drtfname
                retList["nameColor"] = {r = 159, g = 50, b = 49}
                retList["buttonFunc"] = function()
                    self:showTalentInfo(talent,"解锁",function()
                        local text = "学习"..self:clearColorStr(talent.drtfname).."需要"..talent.drtfmoney.."梦境币，是否学习？"                        
                        self._iDreamTalentOutput:setShowConfirmLayer(text,function()
                            self._deamTalentModel:unlockTalent(talentId,function(isSuccess,errmsg)
                                if isSuccess == true then
                                    self._iDreamTalentOutput:popText("解锁成功")
                                    self._iDreamTalentOutput:popText("梦境币-"..tostring(talent.drtfmoney))
                                    self:showDreamCoinsText()
                                    self:initListView()
                                else
                                    self._iDreamTalentOutput:popText(errmsg)
                                end
                            end)
                        end)
                    end,"")
                end
            end
        end

        table.insert(retdata, retList)
    end

    return retdata
end

function DeamTalentPresenter:showTalentInfo(talent,buttonName,buttonFunc,levelDsc)
    local tital = talent.drtfname
    local talentType = talent.drtfuse
    local talenDsc = talent.drtftext
    local drtfmoney = talent.drtfmoney
    -- local levelDsc = Helper:getDef(talent.drlvtext,"")
    local typeDsc = ""
    local tip3 = ""

    if talentType == 1 then
        typeDsc = "主动技能"
        tip3 = "使用天赋技能，"..self._deamTalentModel:getConsumeSorbText(tonumber(string.split(talent.drtfvalue,";")[1]))
    else
        tip3 = ""
        typeDsc = "被动技能"
    end

    local params = {
        tital = tital,
        typeDsc = typeDsc,
        talenDsc = talenDsc,
        levelDsc = levelDsc,
        tip3 = tip3
    }

    self._iDreamTalentOutput:showTalentInfo(params,buttonName,buttonFunc)
end

function DeamTalentPresenter:clearColorStr(text)
    local color = {"HIW","HIY","HIG","HIC","NOR"}
    for j,v in pairs(color) do
        text = string.gsub(text,color[j], "")
    end
    return text
end


isImplement(DeamTalentPresenter, IDreamTalentPresenterInput)
return DeamTalentPresenter
00000000000