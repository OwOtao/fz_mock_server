local User = require("app.models.user.User")
local Skill = require("app.models.skill.Skill")
local SkillPrepareItemUI = require("app.views.ui.SkillUI.SkillPrepareItemUI")

local SkillPrepareLayer = class("SkillPrepareLayer", cc.Layer)

local prepareTypes = {
    SKILL_METHOD_TYPE_QUANJIAO, -- 拳脚
    SKILL_METHOD_TYPE_NEIGONG, -- 内功
    SKILL_METHOD_TYPE_QINGGONG, -- 轻功
    SKILL_METHOD_TYPE_ZHAOJIA, -- 招架
    SKILL_METHOD_TYPE_JIAN, -- 剑法
    SKILL_METHOD_TYPE_DAO, -- 刀法
    SKILL_METHOD_TYPE_GUN, -- 棍法
    SKILL_METHOD_TYPE_ANQI, -- 暗器
    SKILL_METHOD_TYPE_BIANFA, -- 鞭法
    SKILL_METHOD_TYPE_SHUANGCHI, -- 双持
    SKILL_METHOD_TYPE_QIN -- 琴法
}

local prepareList1 = {
    {
        id = "neigong",
        type = SKILL_METHOD_TYPE_NEIGONG,
        name = "基本内功"
    },
    {
        id = "qinggong",
        type = SKILL_METHOD_TYPE_QINGGONG,
        name = "基本轻功"
    },
    {
        id = "zhaojia",
        type = SKILL_METHOD_TYPE_ZHAOJIA,
        name = "基本招架"
    }
}

local prepareList2 = {
    {
        id = "quanjiao1",
        type = SKILL_METHOD_TYPE_QUANJIAO,
        name = "基本拳脚"
    },
    {
        id = "quanjiao2",
        type = SKILL_METHOD_TYPE_QUANJIAO,
        name = ""
    },
    {
        id = "jianfa",
        type = SKILL_METHOD_TYPE_JIAN,
        name = "基本剑法"
    },
    {
        id = "daofa",
        type = SKILL_METHOD_TYPE_DAO,
        name = "基本刀法"
    },
    {
        id = "gunfa",
        type = SKILL_METHOD_TYPE_GUN,
        name = "基本棍法"
    },
    {
        id = "anqi",
        type = SKILL_METHOD_TYPE_ANQI,
        name = "基本暗器"
    },
    {
        id = "bianfa",
        type = SKILL_METHOD_TYPE_BIANFA,
        name = "基本鞭法"
    },
    {
        id = "shuangchi",
        type = SKILL_METHOD_TYPE_SHUANGCHI,
        name = "基本双持"
    },
    {
        id = "qinfa",
        type = SKILL_METHOD_TYPE_QIN,
        name = "基本乐器"
    }
}

function SkillPrepareLayer:create()
    local p = SkillPrepareLayer:new()
    p:init()
    return p
end

function SkillPrepareLayer:init()
    self._UI = require("Layer/SkillUI/SkillPrepareUI.lua").create()["root"]
    self._UI:addTo(self)
    Helper:convertUI(self) -- 获得所有子节点
end

function SkillPrepareLayer:updateLayerSkinUI(skinConfig)
    self.__Skillbtnpic = skinConfig.Skillbtnpic
end

-- SKILL_METHOD_TYPE_QUANJIAO = 1	-- 拳脚
-- SKILL_METHOD_TYPE_NEIGONG = 2 	-- 内功
-- SKILL_METHOD_TYPE_QINGGONG = 3	-- 轻功
-- SKILL_METHOD_TYPE_ZHAOJIA = 4	-- 招架
-- SKILL_METHOD_TYPE_JIAN = 5    	-- 剑法
-- SKILL_METHOD_TYPE_DAO = 6    	-- 刀法
-- SKILL_METHOD_TYPE_GUN = 7   	-- 棍法
-- SKILL_METHOD_TYPE_ANQI = 8    	-- 暗器
-- SKILL_METHOD_TYPE_ANQI = 9    	-- 鞭法

function SkillPrepareLayer:setRole(role)
    self._role = role
end

function SkillPrepareLayer:__isOpenZuoYouHuBo()
    if self._role.isChallengeRole == true or self._role._isFondDrRole == true then
        return false
    else
        return true
    end
end

function SkillPrepareLayer:__getPrepareList2()
    local list = {}
    local isOpen = self:__isOpenZuoYouHuBo()
    for i, v in ipairs(prepareList2) do
        if isOpen == false and v.id == "quanjiao2" then
        else
            table.insert(list, v)
        end
    end
    return list
end

function SkillPrepareLayer:initPrepareSkills()
    self.ListView_prepare1:removeAllItems()
    self.ListView_prepare2:removeAllItems()
    MainControllLayer:getLayer("TitleLayer"):setTextTitle("装备武功")
    local role = self._role
    local skills = role:getSkills()

    local canPrepareTypes = {}
    for k, roleSkill in pairs(skills) do
        local skill = Skill:getSkill(roleSkill.id)
        for k, prepareType in pairs(prepareTypes) do
            if canPrepareTypes[prepareType] == nil and skill:canPrepareType(prepareType) and skill.type ~= SKILL_TYPE_BASE then
                canPrepareTypes[prepareType] = true
            end
        end
    end
    self._prepareItems = {}

    -- 设置UI布局
    for k, prepare in ipairs(prepareList1) do
        if canPrepareTypes[prepare.type] then
            local item = SkillPrepareItemUI:create()
            item:setName(prepare.name)
            item:loadButtonNormalTexture(self.__Skillbtnpic)
            self.ListView_prepare1:pushBackCustomItem(item)
            item.prepare = prepare
            self._prepareItems[prepare.id] = item
        end
    end

    for k, prepare in ipairs(self:__getPrepareList2()) do
        if canPrepareTypes[prepare.type] then
            local item = SkillPrepareItemUI:create()
            item:setName(prepare.name)
            item:loadButtonNormalTexture(self.__Skillbtnpic)
            self.ListView_prepare2:pushBackCustomItem(item)
            item.prepare = prepare
            self._prepareItems[prepare.id] = item
        end
    end

    self:refreshPrepareSkills()
end

function SkillPrepareLayer:refreshPrepareSkills()
    local role = self._role
    local skillPrepare = role:getSkillPrepare()
    if skillPrepare == nil then
        if PRINT_MODE == 1 then
            print("没准备任何武功")
        end
        return false
    end

    for k, item in pairs(self._prepareItems) do
        local prepare = item.prepare
        local prepareSkill = skillPrepare[prepare.id]
        if prepareSkill then
            if PRINT_MODE == 1 then
                print("已装备招式:" .. prepareSkill)
            end
            local roleSkill = role:getSkill(prepareSkill)
            if roleSkill then
                local skill = Skill:getSkill(prepareSkill)
                item:setName(item.prepare.name)
                item.Text_selectSkill:enableOutline(cc.c4b(17, 18, 18, 255), 5)
                item.Text_selectSkill:setFontSize(48)
                item:setButtonText(skill.name)
                item:setSkillStageDsc(skill:getStageDsc(role))
                item:setSkillLv(math.floor(role:getRealSkillLvWithRoleLvLimit(item.prepare.id)) .. "级")
                item.Image_selectSkillTextBack:setVisible(false)
                item.Button_selectSkill:releaseFunc(
                    function()
                        if PRINT_MODE == 1 then
                            print("装备武功")
                        end
                        PopupLayerController:showLayer(
                            "SkillPreparePopLayer",
                            function(layer)
                                layer.skillPrepareLayer = self
                                layer:setSkillType(role, item.prepare.type, item.prepare.id)
                                layer:showWithFade(true, 100)
                            end
                        )
                    end
                )
            else
                item:setName(item.prepare.name)
                item:setButtonText("点击装备武功")
                item.Text_selectSkill:enableOutline(cc.c4b(213, 213, 213, 213), 0)
                item.Text_selectSkill:setTextColor({r = 0, g = 0, b = 0})
                item.Text_selectSkill:setFontSize(42)
                item:setSkillStageDsc("")
                item:setSkillLv(math.floor(role:getRealSkillLvWithRoleLvLimit(item.prepare.id)) .. "级")
                item.Image_selectSkillTextBack:setVisible(false)
                item.Button_selectSkill:releaseFunc(
                    function()
                        if PRINT_MODE == 1 then
                            print("装备武功")
                        end
                        PopupLayerController:showLayer(
                            "SkillPreparePopLayer",
                            function(layer)
                                layer.skillPrepareLayer = self
                                layer:setSkillType(role, item.prepare.type, item.prepare.id)
                                layer:showWithFade(true, 100)
                            end
                        )
                    end
                )
            end
        else
            item:setName(item.prepare.name)
            item:setButtonText("点击装备武功")
            item.Text_selectSkill:enableOutline(cc.c4b(213, 213, 213, 213), 0)
            item.Text_selectSkill:setTextColor({r = 0, g = 0, b = 0})
            item.Text_selectSkill:setFontSize(42)
            item:setSkillStageDsc("")
            item:setSkillLv(math.floor(role:getRealSkillLvWithRoleLvLimit(item.prepare.id)) .. "级")
            item.Image_selectSkillTextBack:setVisible(false)
            if prepare.id == "quanjiao2" and skillPrepare["quanjiao1"] == nil then
                item.Button_selectSkill:setColor({r = 127, g = 127, b = 127})
                item.Button_selectSkill:releaseFunc(
                    function()
                        PopText("请先装备主拳脚武功！")
                    end
                )
            else
                item.Button_selectSkill:setColor({r = 255, g = 255, b = 255})
                item.Button_selectSkill:releaseFunc(
                    function()
                        if PRINT_MODE == 1 then
                            print("装备武功")
                        end
                        PopupLayerController:showLayer(
                            "SkillPreparePopLayer",
                            function(layer)
                                layer.skillPrepareLayer = self
                                layer:setSkillType(role, item.prepare.type, item.prepare.id)
                                layer:showWithFade(true, 100)
                            end
                        )
                    end
                )
            end
        end
    end
end

return SkillPrepareLayer
00