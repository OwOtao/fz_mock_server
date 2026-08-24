local PrepareTalentLayer = class("PrepareTalentLayer", LayerEx)
local DreamTalentModel = require("app.models.DreamWorldModel.DreamTalentModel")

function PrepareTalentLayer:create()
    local p = PrepareTalentLayer:new()
    p:init()
    return p
end

function PrepareTalentLayer:init()
    self._UI = require("Layer/DreamWorldUI/PrepareTalentUI.lua").create()["root"]
    self._UI:addTo(self)
    Helper:convertUIByParent(self)

    --天赋状态
    self.TalentState = {
        NOTOPEN = 0, --@desc 未解锁(周公之术经验不够)
                    
        UNLOCK = 1, --@desc 已解锁(周公之术经验够了，未花梦境币学习)

        LEARN = 2,--@desc 已学习(周公之术经验够了，已经花梦境币学习)
    }
    self.prepareTalent = {} --准备的天赋
    self.dreamTalent = {} --已掌握的天赋

    self:setButtonOK()
end

function PrepareTalentLayer:hideLayer()
    PopupLayerController:hideLayer("PrepareTalentLayer",function(layer)
        layer:hide()
    end)
end

function PrepareTalentLayer:showLayer(list)
    local role = User:getRole()
    self.prepareTalent = clone(role:getAttr("PrepareTalent"))
    self.dreamTalent = role:getAttr("DreamTalent")
    self:setTitle()
    self:initPopTalent(list)
    self:show()
end

function PrepareTalentLayer:setTitle()
    self.Text_title:setString("准备天赋")
end

function PrepareTalentLayer:initPopTalent(list)
    self.ListView_1:removeAllItems()
    if MapIsEmpty(list) then
        return
    end

    table.sort(list, function(talent,talent2)
        local id = talent.id
        local id2 = talent2.id
        local isPrepare = DreamTalentModel:checkTalentIdIsEmpty(self.prepareTalent,id)
        local isPrepare2 = DreamTalentModel:checkTalentIdIsEmpty(self.prepareTalent,id2)
        local isUnlock = DreamTalentModel:checkTalentIdIsEmpty(self.dreamTalent,id)
        local isUnlock2 = DreamTalentModel:checkTalentIdIsEmpty(self.dreamTalent,id2)

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
                return id < id2
            elseif not isUnlock and isUnlock2 then
                return false
            elseif not isUnlock and not isUnlock2 then
                return id < id2
            end
        end
    end)
                        
    for i, talent in ipairs(list) do
        if talent then
            local panel = self.Panel_item:clone()
            
            Helper:convertUIByParent(panel)
            local state = 0 --天赋状态
            local talentId = talent.id
            if DreamTalentModel:checkTalentIdIsEmpty(self.dreamTalent,talentId) == true then
                state = self.TalentState.LEARN
                panel.Button_2.Text_name:setString(talent.drtfname)
                panel.Button_2.Text_name:setTextColor({r = 209, g = 190, b = 74})
            else
                local needExp = talent.drtfexp --所需经验值
                local skillId = "zhougongzhishu"
                if  DEBUG_MODE == 1 then
                    skillId = "dushushizi"
                end
                local zgzsExp = User:getRole():getSkillExp(skillId)
                print("zgzsExp = ",zgzsExp,"needExp = ",needExp)
                if zgzsExp < needExp then
                    state = self.TalentState.NOTOPEN
                    panel.Button_2.Text_name:setString("-----")
                    panel.Button_2.Text_name:setTextColor({r = 255, g = 255, b = 255})
                else
                    state = self.TalentState.UNLOCK
                    panel.Button_2.Text_name:setString(talent.drtfname)
                    panel.Button_2.Text_name:setTextColor({r = 159, g = 50, b = 49})
                end
            end

            self:setPrepareButton(panel,talentId,state)
            
            panel.Button_2:releaseFunc(function()
                self:showTalentInfo(talent,state)
            end)

            self.ListView_1:pushBackCustomItem(panel)
        end
    end
end

function PrepareTalentLayer:setPrepareButton(row,talentId,state)
    if row == nil or talentId == nil or state == nil then
        return
    end
    if state == 2 then
        row.Button_1:setEnabled(true)
        if DreamTalentModel:checkTalentIdIsEmpty(self.prepareTalent,talentId) == true then
            row.dian:setVisible(true)
            row.Button_1.Text_buttonName:setString("取消准备")
            row.Button_1:releaseFunc(function()
                self.prepareTalent[tostring(talentId)] = nil
                self:setPrepareButton(row,talentId,state)
            end)
        else
            row.dian:setVisible(false)
            row.Button_1.Text_buttonName:setString("准备")
            row.Button_1:releaseFunc(function()
                local count = 0
                for k,v in pairs(self.prepareTalent) do
                    count = count + 1
                end
                
                if count >= 3 then
                    PopText("最多准备三个天赋技能")
                    return
                end
                self.prepareTalent[tostring(talentId)] = true
                self:setPrepareButton(row,talentId,state)
            end)
        end
    else
        row.dian:setVisible(false)
        row.Button_1.Text_buttonName:setString("准备")
        row.Button_1:setEnabled(false)
    end
end

function PrepareTalentLayer:showTalentInfo(talent,state)
    if talent == nil or state == nil then
        return
    end

    local tital = talent.drtfname
    local talentType = talent.drtfuse
    local typeDsc = "主动技能"
    local talenDsc = talent.drtftext
    local levelDsc = Helper:getDef(talent.drlvtext,"")
    local Skill = require("app.models.skill.Skill")
    -- local tip1 = "周公之术等级要求:"..Skill:getLv(talent.drtfexp)
    -- local drtfmoney = talent.drtfmoney or 0
    -- local tip2 = "解锁需消耗梦境币:"..drtfmoney
    local tip3 = ""
    local drtfvalue = talent.drtfvalue
    if drtfvalue then
        drtfvalue = tonumber(string.split(drtfvalue,";")[1])
        tip3 = "使用天赋技能，"..DreamTalentModel:getConsumeSorbText(drtfvalue)
    end

    if state == 0 then
        PopText("经验不够，未解锁")
        return
    elseif state == 1 then
        levelDsc = ""
    elseif state == 2 then
        -- tip1 = ""
        -- tip2 = ""
    else
        error("未知状态")
    end

    PopupLayerController:showLayer("DreamTalentInfoLayer", function(layer)
        layer:setTitle(tital)
        layer:setTalentTypeText(typeDsc)
        layer:setTalentDsc(talenDsc)
        layer:setUnlockButton(nil)
        layer:setDesc1(levelDsc)
        layer:setDesc3(tip3)
        layer:showLayer()
    end)
end

function PrepareTalentLayer:setButtonOK()
    self.Button_ok:releaseFunc(function()
        local role = User:getRole()
        role:setAttr("PrepareTalent",self.prepareTalent)
        self:hideLayer()
	end)
end

Helper:classDefNodeGetInstance(PrepareTalentLayer)
return PrepareTalentLayer
0000000