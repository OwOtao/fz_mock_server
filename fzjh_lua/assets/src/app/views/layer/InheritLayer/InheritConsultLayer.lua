local User = require("app.models.user.User")
local Item = require("app.models.item.Item")
local Resource = require("app.Resource")

-- 师父技能列表
local SkillInfoLIstBarUI = require("app.views.ui.SkillUI.SkillInfoListBarUI")
local SkillInfoTabBarUI = require("app.views.ui.SkillUI.SkillInfoTabBarUI")

-- 技能详细信息弹出框
local SkillInfoPopNormalUI = require("app.views.ui.SkillUI.SkillInfoPopNormalUI")
local SkillInfoPopSpecialUI = require("app.views.ui.SkillUI.SkillInfoPopSpecialUI")

-- 首次请教所需江湖阅历
local consultNeedYueLi = {10000, 15500, 21000, 26500, 32000}
-- 阅历递增
local consultYueLiAdd = {100, 110, 120, 130, 140}

local InheritConsultLayer = class("InheritConsultLayer", LayerEx)

local SKILL_FROM_TYPE = {
    LOCAL = 1,
    NET = 2
}

function InheritConsultLayer:create()
    local p = InheritConsultLayer:new()
    p:init()
    return p
end

function InheritConsultLayer:init()
    local UI = require("Layer/InheritUI/InheritConsultUI.lua").create()["root"]
    UI:addTo(self)

    Helper:convertUIByParent(self)

    self.inheritIndex = 0

    self.inheritRoleInfo = nil

    self:setVisible(false)

    self:setShowAndHideAnimType("ROLL")

    self:setBack()

    self:initPopUI()

    self:setButton()

    self.lastTouchSkill = nil
end

function InheritConsultLayer:initPopUI()
    if self.skillInfoPopSpecialUI == nil then
        self.skillInfoPopSpecialUI = SkillInfoPopSpecialUI:create()
        self.skillInfoPopSpecialUI:addTo(self)
    end
    self.PIs_show = false
    self.skillInfoPopSpecialUI:hide()
end

-- 设置按钮
function InheritConsultLayer:setButton()
    self.Button_Consult:releaseFunc(
        function()
            if self.lastTouchSkill == nil then
                PopText("未选择技能")
                return
            end

            local inheritConsultCount = self._player:getAttr("inheritConsultCount")
            local inheritCount = self._player:getAttr("inheritCount")

            local skill = self._player:getSkill(self.lastTouchSkill.id)

            -- 判断阅历是否足够
            local yueli = self._player:getAttr("yueli")

            if yueli < consultNeedYueLi[inheritCount] + (inheritConsultCount * consultYueLiAdd[inheritCount]) then
                PopText("江湖阅历不足")
                return
            end

            if self.lastTouchSkill.fromType == SKILL_FROM_TYPE.LOCAL then
                -- 如果是长生诀 继承全部经验
                local skillExp = math.ceil(self.lastTouchSkill.exp / 2)

                if self.lastTouchSkill.id == "changshengjue" then
                    skillExp = math.ceil(self.lastTouchSkill.exp)
                end

                if skill == nil then
                    self:studySkill(self.lastTouchSkill.id, skillExp)
                elseif skill.exp < skillExp then
                    self:studySkill(self.lastTouchSkill.id, skillExp)
                else
                    PopText(Skill:getSkill(self.lastTouchSkill.id).name .. " 经验超出，无法请教")
                end
            elseif self.lastTouchSkill.fromType == SKILL_FROM_TYPE.NET then
                PopupLayerController:showLayer(
                    "GlobalShadeLayer",
                    function(layer)
                        layer:showLayer()
                        layer:setPopText("正在学习，请稍等。")
                    end
                )

                local skillExp = math.ceil(self.lastTouchSkill.exp / 2)

                local studyNetSkill = function ()
                    HttpManagerEx:studyOtherSkill(
                        self.inheritUserId,
                        self.lastTouchSkill.id,
                        function(status, errcode, errmsg, data)
                            if status == 200 then
                                if errcode == 0 then
                                    self:studySkill(self.lastTouchSkill.id, skillExp)
                                else
                                    PopText(errmsg)
                                end
                            else
                                PopText(errmsg)
                            end
                            PopupLayerController:hideLayer(
                                "GlobalShadeLayer",
                                function(layer)
                                    layer:hideLayer()
                                end
                            )
                        end,
                        IS_SHOW_WAITING
                    )
                end

                if skill == nil then
                    studyNetSkill()
                elseif skill.exp < skillExp then
                    studyNetSkill()
                else
                    PopupLayerController:hideLayer(
                        "GlobalShadeLayer",
                        function(layer)
                            layer:hideLayer()
                        end
                    )
                    PopText(Skill:getSkill(self.lastTouchSkill.id).name .. " 经验超出，无法请教")
                end
            else
                error("该技能出处未知，请检查。")
            end
        end
    )
end

function InheritConsultLayer:studySkill(skillId, skillExp)
    local skill = Skill:getSkill(self.lastTouchSkill.id)

    if self._player:getSkill(self.lastTouchSkill.id) == nil then
        PopText("你学会了 " .. skill.name)
        RichPrint("main", "你学会了 " .. "【" .. skill.name .. "】")
    end

    PopText(skill.name .. " 等级提升")

    self._player:setSkill(self.lastTouchSkill.id, {id = self.lastTouchSkill.id, exp = skillExp})
    self._player:addAttr("inheritConsultCount", 1)

    self.localSkillList = self:initLocalSkillList()
    self.netSkillList = self:initNetSkillList(self.netSkillList)
    self:showListView(self:getRenderList())
end

function InheritConsultLayer:initTableView()
    local outlineWidth = 5
    local textColor = cc.c3b(234, 234, 234)
    local outlineColor = cc.c4b(44, 51, 54, 255)

    self.Image_tab.ListView_tab:removeAllItems()

    local panel = self.Panel_back_title:clone()
    Helper:convertUIByParent(panel)
    panel.Text_title:setString(self.inheritRoleInfo.parentName)
    panel.Text_title:setColor(textColor)
    panel.Text_title:enableOutline(outlineColor, outlineWidth)
    self.Image_tab.ListView_tab:pushBackCustomItem(panel)
end

-- 设置文本
function InheritConsultLayer:setText()
    local needYueLi = self._player:getAttr("inheritConsultCount")
    local inheritCount = self._player:getAttr("inheritCount")

    self.Text_yueli:setString(math.floor(self._player:getAttr("yueli")))
    self.Text_need_yueli:setString(consultNeedYueLi[inheritCount] + (needYueLi * consultYueLiAdd[inheritCount]))
end

function InheritConsultLayer:setBack()
    self.Panel_back:releaseFunc(
        function()
            self:hideLayer()
        end
    )
end

-- 控制背景显示隐藏
function InheritConsultLayer:setImageBack(cItem)
    local items = self.ListView_titlelistArea:getItems()
    for k, item in pairs(items) do
        if cItem == item then
            item:setImageBack(true)
            self._currIndex = k
        else
            item:setImageBack(false)
        end
    end
end

function InheritConsultLayer:showLayer(currRole, player)
    PopupLayerController:showLayer(
        "GlobalShadeLayer",
        function(layer)
            layer:showLayer()
            layer:setPopText("请稍等。")
        end
    )
    self.ListView_titlelistArea:removeAllItems()

    self._player = player

    self.inheritIndex = currRole.inheritIndex

    HttpManagerEx:getOtherSkills(
        self.inheritIndex,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    self.inheritUserId = data.userid

                    local net_list = {}
                    if MapIsEmpty(data.list) == false then
                        for skillId, exp in pairs(data.list) do
                            table.insert(net_list, {id = skillId, exp = exp, fromType = SKILL_FROM_TYPE.NET})
                        end
                    end

                    self.localSkillList = self:initLocalSkillList()

                    self.netSkillList = self:initNetSkillList(net_list)

                    local render_list = self:getRenderList()

                    if MapIsEmpty(render_list) == true then
                        RichPrint("main", "YEL" .. currRole.name .. "：我已经无法教你更多了")
                        self:hideLayer()
                        PopupLayerController:hideLayer(
                            "GlobalShadeLayer",
                            function(layer)
                                layer:hideLayer()
                            end
                        )
                        return
                    end

                    self:showListView(self:getRenderList())

                    self:initTableView()

                    self:setText()

                    self:show()
                else
                    PopText(errmsg)
                    self:hideLayer()
                end
            else
                PopText(errmsg)
                self:hideLayer()
            end
            PopupLayerController:hideLayer(
                "GlobalShadeLayer",
                function(layer)
                    layer:hideLayer()
                end
            )
        end,
        IS_SHOW_WAITING
    )
end

function InheritConsultLayer:initLocalSkillList()
    local inheritHistory = self._player:getAttr("inheritHistory")

    local skillList = {}

    self.inheritRoleInfo = inheritHistory[self.inheritIndex]

    local jianghuSkills = self.inheritRoleInfo.parentSkills

    if jianghuSkills == nil then
        return skillList
    end

    for k, v in pairs(jianghuSkills) do
        local ret = true
        --@desc 防止学习长生诀阴阳后 又可从传承角色中学习100-500级长生诀
        if v.id == "changshengjue" and (self._player:getSkill("changshengjueyin") or self._player:getSkill("changshengjueyang")) then
            ret = false
        end

        if ret then
            local skill_info = {
                id = v.id,
                exp = v.exp,
                fromType = SKILL_FROM_TYPE.LOCAL
            }

            if self._player:getSkill(skill_info.id) == nil then
                -- 未学会可请教
                table.insert(skillList, skill_info)
            else
                -- 已经学会检测技能经验是否不足前辈技能1/2 不足也可以请教
                local skill = self._player:getSkill(skill_info.id)

                local skillExp
                if skill.id == "changshengjue" then
                    -- 如果是长生诀继承所有经验
                    skillExp = math.ceil(skill_info.exp)
                else
                    skillExp = skill_info.exp / 2
                end

                if skill.exp < skillExp then
                    table.insert(skillList, skill_info)
                end
            end
        end
    end

    return skillList
end

function InheritConsultLayer:initNetSkillList(netSkillList)
    local skillList = {}

    if MapIsEmpty(netSkillList) == true then
        return skillList
    end

    for i = 1, #netSkillList do
        local skill_info = netSkillList[i]

        --@desc 需排除当前门派武学
        local base_skill_info = Skill:getSkill(skill_info.id)

        if  not self._player:hasFamily() or base_skill_info:isUnSectSkill(self._player:getFamilyId()) then
            -- 已经学会检测技能经验是否不足前辈技能1/2 不足也可以请教
            local skill = self._player:getSkill(skill_info.id)

            local skillExp = skill_info.exp / 2

            if skill == nil then
                table.insert(skillList, skill_info)
            elseif skill.exp < skillExp then
                table.insert(skillList, skill_info)
            end
        end
    end

    return skillList
end

function InheritConsultLayer:getRenderList()
    local render_list = {}

    if MapIsEmpty(self.localSkillList) == false then
        for i = 1, #self.localSkillList do
            table.insert(render_list, self.localSkillList[i])
        end
    end

    if MapIsEmpty(self.netSkillList) == false then
        for i = 1, #self.netSkillList do
            table.insert(render_list, self.netSkillList[i])
        end
    end

    return render_list
end

function InheritConsultLayer:showListView(render_skill_list)
    self.ListView_titlelistArea:removeAllItems()

    table.sort(
        render_skill_list,
        function(a, b)
            return a.id < b.id
        end
    )

    for i, v in pairs(render_skill_list) do
        local skillInfoListBar = SkillInfoLIstBarUI:create()
        self.ListView_titlelistArea:pushBackCustomItem(skillInfoListBar)

        local skill = Skill:getSkill(v.id)
        local skillLv = skill:getLv(v.exp)
        local skillExp = v.exp

        skillInfoListBar:setName(skill:getName())
        skillInfoListBar:setStageDsc(skill:getSkillDescForValid(skillLv))
        skillInfoListBar:setExpDsc(skillLv .. "级")
        skillInfoListBar:setDian(false)

        skillInfoListBar:releaseFunc(
            function()
                Audio:playEffect("daAnNiu")
                if skill.id == "changshengjue" then
                    PopText("请教成功可继承该武功及全部经验")
                end
                local items = self.ListView_titlelistArea:getItems()
                for k, item in pairs(items) do
                    item:setDian(false)
                end

                self.lastTouchSkill = v
                skillInfoListBar:setDian(true)
            end
        )
    end
end

function InheritConsultLayer:hideLayer()
    PopupLayerController:hideLayer(
        "InheritConsultLayer",
        function(layer)
            self.inheritUserId = nil
            self.lastTouchSkill = nil
            layer:hide()
        end
    )
end

Helper:classDefNodeGetInstance(InheritConsultLayer)

return InheritConsultLayer
0000000000000000