local MapActivePractice = class("MapActivePractice", cc.Layer)

local page

local _map

local _partner

local list = {}

function MapActivePractice:create()
    local p = MapActivePractice:new()
    p:init()
    return p
end

function MapActivePractice:init()
    self._UI = require("Layer/Dialog/ItemSelectUI.lua").create()["root"]
    self._UI:addTo(self)
    Helper:convertUIByParent(self)
    self.Button_Back:setVisible(true)
    self:setBack()
end

function MapActivePractice:hideLayer()
    PopupLayerController:hideLayer(
        "MapActivePractice",
        function(layer)
            layer:hide()
        end
    )
end

function MapActivePractice:setTitle(text)
    if text == nil then
        text = ""
    end

    self.Text_Title:setString(text)
end

function MapActivePractice:showLayer(map, partner)
    _map = map

    _partner = partner

    self:initZhaoList()
    self:setBtnBackAndTitle()
    self:showList()
end

--@desc: 初始化被动招式列表
--@author:Liang SongQiang
--@time:2018-05-28 14:37:25
--@skillId: 被动招式Id
function MapActivePractice:initZhaoList()
    list = {}

    --@RefType [app.models.role.Role#Role]
    local role = User:getRole()

    local zhaoIdList = _partner.extra.zhaoIdList
    
    if MapIsEmpty(zhaoIdList) then
        PopText("你的陪练没有学习任何招式。")
        return
    end

    local skillIdList = {}
    local temp = {}
    for i,v in ipairs(zhaoIdList) do
        local skillId = Skill:getSkillIdByZhaoId(v)
        temp[skillId] = true
    end

    for skillId,v in pairs(temp) do
        table.insert( skillIdList,skillId )
    end

    local function filter(skillId)
        local str = string.find(skillId, "jiben")

        if str then
            return false
        end

        local skill = Skill:getSkill(skillId)
        if
            skill.type == SKILL_TYPE_DUSHU or skill.type == SKILL_TYPE_SPECIAL or skill.type == SKILL_TYPE_HUIFU or
                skill.type == SKILL_TYPE_DUNDI or
                skill.type == SKILL_TYPE_ZHISHI
         then
            return false
        end

        return true
    end

    for k, v in pairs(skillIdList) do
        if filter(v) then
            local skill = Skill:getSkill(v)
            local temp = {}
            temp.id = v
            temp.name = skill.name
            table.insert(list, temp)
        end
    end

    if MapIsEmpty(list) then
        PopText("您没有可练习的武功。")
    end

    self.btnFunc = function(id)
        local zhaos = Skill:getSkillZhaoMap(id)

        if MapIsEmpty(zhaos) then
            PopText("该武功没有特殊招式！")
            return
        end

        self:initActiveZhaoList(id)
        self:setBtnBackAndTitle()
        self:showList()
    end

    page = 1
end

function MapActivePractice:initActiveZhaoList(skillId)
    list = {}
    local zhaos = Skill:getSkillZhaoMap(skillId)

    for k, v in pairs(zhaos) do
        if self:cheakHaveZhaoId(k) then
            local temp = {}

            local activeZhao = Skill:getActiveZhao(k)

            temp.id = k

            temp.name = activeZhao.name

            table.insert(list, temp)
        end
    end

    self.btnFunc =
        function(id)
        --@RefType [app.models.role.Role#Role]
        local role = User:getRole()
        local jing = role:getAttr("jing")

        local zhaoLv = role:getSkillZhaoLv(id)
        if zhaoLv == 0 then
            PopText("该特殊招式你还未习得！")
            return
        end

        local activeZhao = Skill:getActiveZhao(id)

        --@RefType [app.models.HomelandModel.HomelandRoleUtil#HomelandRoleUtil]
        local HomelandRoleUtil = require("app.models.HomelandModel.HomelandRoleUtil")
        local zcLv = HomelandRoleUtil:getFidelityLv(_partner.defaultZhongCheng)
        local isPractice = false
        if activeZhao:getLevel() == "" then
            assert(false," MapActivePractice:initActiveZhaoList 资源招式强度字段没填")
        end
        if zcLv < 3 and activeZhao:getLevel() <= 2 then
            isPractice = true
        elseif zcLv >= 3 and zcLv < 5 and activeZhao:getLevel() <= 3 then
            isPractice = true
        elseif zcLv >= 5 and zcLv <= 7 and activeZhao:getLevel() <= 4 then
            isPractice = true
        end
        
        if not isPractice then
            PopText("忠诚度等级不足，无法陪练该招式")
            return
        end

        local int = role:getFinalAttr("int")
        local m = role:getSkillZhaoPotEfficiency(id)
        local subJing = math.min(250 / m * (zhaoLv + 2) + 10, 120)
        if zcLv >= 6 then
            subJing = subJing*0.5
        end
        if jing < subJing then
            PopText("您精力不足，无法练习。")
            return
        end

        local addExp = (zhaoLv + 2) * m / 10 + int / 10 + 5
        if zcLv == 7 then
            addExp = addExp*(1+0.2)
        end
        local ret, addExp, msg = role:checkSkillZhaoCanUp(id, addExp)

        if ret == false then
            PopText(msg)
            return
        end

        if addExp == 0 then
            PopText("你的招式熟练度已达最高，无法练习")
            return
        end

        role:addSkillZhaoExp(id, addExp)
        role:addAttr("jing",-subJing)

        local purenId = _partner.id
        local currDayPLCount = role:getDayFlag("plnum"..purenId)
        role:setDayFlag("plnum"..purenId,currDayPLCount + 1)

        if DEBUG_MODE == 1 then
            print("int = ",int)
            print("m = ",m)
            print("zhaoLv = ",zhaoLv)
            print("此次消耗精力：", subJing)
            print("此次增加经验：", addExp)
        end
        local skillId = Skill:getSkillIdByZhaoId(id)

        local skillName = Skill:getSkill(skillId).name

        local zhaoName = Skill:getActiveZhao(id).name

        local text = {
            "你招来$npcName$ ，与其对练起了$skillName$ 中的$aName$ 。",
            "你全神贯注于练习招式上，不知不觉进入了忘我的境界。",
            "时间慢慢过去，在不断地练习中，$aName$ 被你运用得越来越纯熟。",
            "待你回过神来，已是小半个时辰过去了。",
            "你感觉你所用的$aName$ 大有进益，心中对武学的感悟又多了不少。"
        }

        PopupLayerController:showLayer(
            "GlobalShadeLayer",
            function(layer)
                layer:setPopText("您正在练功，请专心")
                layer:showLayer()
            end
        )

        for i = 1, #text do
            _map.__MapLayer:delayFunc(
                0 + (i - 1) * 2,
                function()
                    local str = text[i]

                    str = string.gsub(str, "$npcName$ ", _partner.name)
                    str = string.gsub(str, "$skillName$ ", skillName)
                    str = string.gsub(str, "$aName$ ", zhaoName)

                    RichPrint("main", str)

                    if i == #text then
                        RichPrint("main", zhaoName .. " 熟练度 +" .. math.floor(addExp))
                        PopupLayerController:hideLayer(
                            "GlobalShadeLayer",
                            function(layer)
                                layer:hideLayer()
                            end
                        )
                    end
                end
            )
        end

        self:hideLayer()
    end

    page = 2
end

function MapActivePractice:showList()
    if MapIsEmpty(list) then
        self:hideLayer()
        return
    end

    self.Item_List:removeAllItems()
    local mod, remainder = math.modf(#list / 2)

    if math.ceil(remainder) == 1 then
        mod = mod + 1
    end

    local pList = {}
    for i = 1, mod do
        local panel = self.Panel_List:clone()
        Helper:convertUIByParent(panel)
        panel.Button_Left:setVisible(false)
        panel.Button_Right:setVisible(false)
        panel.Button_Left.Text_name:enableOutline({r = 26, g = 26, b = 26, a = 255}, 5)
        panel.Button_Right.Text_name:enableOutline({r = 26, g = 26, b = 26, a = 255}, 5)
        table.insert(pList, panel)
    end

    for index, data in ipairs(list) do
        local pListIndex = math.ceil(index / 2)
        local panel = pList[pListIndex]

        if index % 2 == 1 then
            panel.Button_Left:setVisible(true)
            panel.Button_Left.Text_name:setString(data.name)
            panel.Button_Left:releaseFunc(
                function()
                    self.btnFunc(data.id)
                end
            )
        elseif index % 2 == 0 then
            panel.Button_Right:setVisible(true)
            panel.Button_Right.Text_name:setString(data.name)
            panel.Button_Right:releaseFunc(
                function()
                    self.btnFunc(data.id)
                end
            )
        else
            assert(false, "代码有问题！！")
        end
    end

    for i, panel in ipairs(pList) do
        self.Item_List:pushBackCustomItem(panel)
    end

    self:show()
end

function MapActivePractice:setBtnBackAndTitle()
    if page == 2 then
        self:setTitle("你要对练哪一式绝学呢？")
        self.Button_Back.Text_name:setString("返回")
        self.Button_Back:releaseFunc(
            function()
                self:initZhaoList()
                self:showList()
                self:setBtnBackAndTitle()
            end
        )
    elseif page == 1 then
        self:setTitle("你要对练哪一门武功的招式呢？")
        self.Button_Back.Text_name:setString("关闭")
        self.Button_Back:releaseFunc(
            function()
                self:hideLayer()
            end
        )
    end
end

function MapActivePractice:setBack()
    self.Panel_back:releaseFunc(
        function()
            self:hideLayer()
        end
    )
end

--检查保存的招式列表是否有这个招式 
function MapActivePractice:cheakHaveZhaoId(zhaoId)
    local zhaoIdList = Helper:getDef(_partner.extra.zhaoIdList,{})
    if MapIsEmpty(zhaoIdList) then
        return false
    end
    for k,v in pairs(zhaoIdList) do
        if zhaoId == v then
            return true
        end    
    end 

    return false
end

Helper:classDefNodeGetInstance(MapActivePractice)
return MapActivePractice
000000000000000