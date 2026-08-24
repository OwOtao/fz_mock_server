local NewClass = require("third.class.NewClass")
local AbstractUseItem = require("app.models.role.item.UseItem.AbstractRoleUseItem")
local Item = require("app.models.item.Item")

local RoleUseItem_SkillBook = {}
--长生诀阴阳学习状态
local ChangShengJueYinAndYangLearnState = false

function RoleUseItem_SkillBook:__doUseItem()
    local item = self._item
    local role = self._role

    local bookSkills = require("app.models.book.BookSkills")
    local skills = clone(bookSkills:getbookSkill())

    if item.skillid == nil then
        return
    end

    local currSkillData
    for id, skill in pairs(skills) do
        if skill.skillId == item.skillid then
            currSkillData = skill
            break
        end
    end

    if bookSkills:checkSkillCanLearn(item.skillid, currSkillData) then
        if
            item.id == "changshengjueshengji2" or item.id == "changshengjueshengji3" or item.id == "changshengjueshengji4" or item.id == "changshengjueshengji5" or item.id == "shuye93" or
                item.id == "changshengjueyin" or
                item.id == "changshengjueyang"
         then
            self:__changShengBook(role)
            return
        end

        if item.id == "zouxueshisijing1" or item.id == "zouxueshisijing2" then
            self:__zouXueJing(role)
            return
        end

        local page

        -- 自定义经验
        local bookExp

        -- 寻找对应技能
        for id, skill in pairs(skills) do
            if skill.skillId == item.skillid then
                page = skill.page
                bookExp = skill.exp
                break
            end
        end

        local skill = Skill:getSkill(item.skillid)

        if page == nil then
            print("没有该技能 " .. item.skillid)
            return
        end

        -- 是否已经学会技能
        if role:getSkill(item.skillid) ~= nil then
            local skill = Skill:getSkill(item.skillid)

            local index = 1
            local pot = 500
            -- 根据书页索引获取经验加成
            for i, v in pairs(page) do
                if v.name == item.id then
                    index = i
                    break
                end
            end

            if index == 1 then
                pot = 500
            elseif index == 2 then
                pot = 1000
            elseif index == 3 then
                pot = 2000
            elseif index == 4 then
                pot = 4166
            elseif index == 5 then
                pot = 12500
            end

            local exp = pot * (skill:getPotEfficiency(role) / 100)

            -- 如果填写了自定义经验，就增加对应的经验
            if bookExp ~= nil then
                exp = tonumber(string.split(bookExp, ";")[index])
            end

            if role:canLevelUp(item.skillid, exp) == true then
                local function useItemBook()
                    local skillLv = skill:getLv(role:getSkill(item.skillid).exp + exp)
                    if Skill:canLevelUp(role, skill, skillLv) == true then
                        self:__richPrint("【" .. skill.name .. "】" .. "经验 + " .. math.floor(exp))
                        role:addSkillExp(item.skillid, exp)
                        role:addItemCount(item.id, -1)
                    else
                        self:__popText(Skill:canLevelUp(role, skill, skillLv))
                    end
                end
                if role:getSkillExp(item.skillid) >= role:conversionSkillExpAndLv("exp", role:getSkillLvLimit(item.skillid)) then
                    self:__popText("当前武学经验超出上限，书页使用失败")
                elseif role:getSkillExp(item.skillid) + exp > role:conversionSkillExpAndLv("exp", role:getSkillLvLimit(item.skillid)) then
                    local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
                    local dialog = DialogALayer:getInstance()
                    dialog:hide()
                    local text = "使用"..Helper:getNoColorStr(item.name).."书页后，获取经验会超出当前经验最大值，是否使用？"
                    dialog:show(text)
                    dialog:setButton1(
                        "确定",
                        function()
                            useItemBook()
                        end
                    )
                    dialog:setButton2(
                        "取消",
                        function()
                        end
                    )
                    dialog:setWeChatVisible(false)
                else
                    useItemBook()
                end
               
            else
                self:__popText(role:canLevelUp(item.skillid, exp))
            end
        else
            -- 检测是否集齐所有书页
            if page ~= nil then
                local flag = true
                for k, v in pairs(page) do
                    if role:getItem(v.name) == nil or role:getItem(v.name).count <= 0 then
                        flag = false
                        self:__popText("需集齐此书全部残页方可学习")
                        break
                    end
                end

                --集齐书页学习该技能
                if flag then
                    -- 学习技能经验 按照自定义经验增加，没有默认1
                    local exp = 1
                    if bookExp ~= nil then
                        exp = tonumber(string.split(bookExp, ";")[1])
                    end
                    if role:canLevelUp(item.skillid, exp) == true then
                        if Skill:canLevelUp(role, skill, exp) == true then
                            if bookExp ~= nil then
                                role:setSkill(item.skillid, {id = item.skillid, exp = exp})
                            else
                                role:setSkill(item.skillid, {id = item.skillid, exp = exp})
                            end
                            for k, v in pairs(page) do
                                role:addItemCount(v.name, -1)
                            end
                        else
                            self:__popText(Skill:canLevelUp(role, skill, exp))
                        end
                    else
                        self:__popText(role:canLevelUp(item.skillid, exp))
                    end
                end
            end
        end

        self:__onUseAft()
    end

    return true
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/05/04 17:19:36
-- @desc 长生诀书页特殊处理
--@role: [src.app.models.role.Role#Role]
function RoleUseItem_SkillBook:__changShengBook()
    local item = self._item
    local role = self._role

    if role:getInheritFlag("item_" .. item.id) == true then
        self:__popText("该图谱只能学习一次")
    elseif role:getInheritFlag("item_changshengjueyinoryang") == true then
        if role:getSkill("changshengjueyin") and item.id == "changshengjueyang" then
            self:__popText("您已习得长生诀阴，无法学习长生诀阳篇。")
        elseif role:getSkill("changshengjueyin") and item.id == "changshengjueyin" then
            self:__popText("该图谱只能学习一次")
        end

        if role:getSkill("changshengjueyang") and item.id == "changshengjueyin" then
            self:__popText("您已习得长生诀阳，无法学习长生诀阴篇。")
        elseif role:getSkill("changshengjueyang") and item.id == "changshengjueyang" then
            self:__popText("该图谱只能学习一次")
        end

        if not role:getSkill("changshengjueyin") and not role:getSkill("changshengjueyang") then
            if item.id == "changshengjueyin" or item.id == "changshengjueyang" then
                self:__popText("正在学习中")
            end
        end
    elseif role:getSkill(item.skillid) ~= nil and item.id ~= "changshengjueyin" and item.id ~= "changshengjueyang" then
        local skillLv = Helper:getDef(role:getSkillLv(item.skillid), 0)
        local skillLvTab = {
            shuye93 = 0,
            changshengjueshengji2 = 100,
            changshengjueshengji3 = 200,
            changshengjueshengji4 = 300,
            changshengjueshengji5 = 400
        }

        local result = false
        if skillLvTab[item.id] ~= nil and skillLv >= skillLvTab[item.id] then
            result = true
        else
            result = false
        end
        if result == false then
            self:__richPrint("长生诀学习需循序渐进，你功力未深，还不能学习。")
        else
            local addLv = math.max(0, skillLvTab[item.id] + 100 - skillLv)
            self:__richPrint("你拿起图谱仔细研读，发现其上所述图文与之前所学的长生诀行气路线颇为相似，在你努力专研之下，终于将其参悟。")
            self:__richPrint("HIW【长生诀】NOR" .. "等级 + " .. math.floor(addLv))
            role:addSkillLv(item.skillid, addLv)
            role:addItemCount(item.id, -1)
            role:setInheritFlag("item_" .. item.id, true)
        end
    elseif item.id == "shuye93" then
        self:__richPrint("你拿起图谱仔细研读，发现其上所述图文与之前所学的长生诀行气路线颇为相似，在你努力专研之下，终于将其参悟。")
        self:__richPrint("HIW【长生诀】NOR" .. "等级 + " .. math.floor(100))
        role:addSkillLv(item.skillid, 100)
        role:addItemCount(item.id, -1)
        role:setInheritFlag("item_" .. item.id, true)
    elseif item.id == "changshengjueyin" or item.id == "changshengjueyang" then
        if ChangShengJueYinAndYangLearnState == true then
            self:__popText("正在学习中")
            return
        end

        local result = true
        if role:getSkill("changshengjue") == nil then
            self:__richPrint("你拿起这张图谱细细研读，但上刻字符晦涩难懂，你想了许久也没有头绪。")
            result = false
        elseif role:getSkillLv("changshengjue") < 500 then
            self:__richPrint("长生诀学习需循序渐进，你功力未深，还不能学习。")
            result = false
        end

        if result then
            ChangShengJueYinAndYangLearnState = true
            if item.id == "changshengjueyin" then
                role._iOutput:showLearnChangShengJueYin(
                    function()
                        role:setInheritFlag("item_changshengjueyinoryang", true)

                        role.skills["changshengjue"] = nil
                        local exp = role:conversionSkillExpAndLv("exp", 600)
                        local roleSkill = {id = item.id, exp = exp}
                        role:setSkill(item.id, roleSkill)
                        role:addItemCount(item.id, -1)
                        ChangShengJueYinAndYangLearnState = false

                        self:__onUseAft()
                    end,
                    function()
                        ChangShengJueYinAndYangLearnState = false
                    end
                )
            elseif item.id == "changshengjueyang" then
                role._iOutput:showLearnChangShengJueYang(
                    function()
                        role:setInheritFlag("item_changshengjueyinoryang", true)

                        role.skills["changshengjue"] = nil
                        local exp = role:conversionSkillExpAndLv("exp", 600)
                        local roleSkill = {id = item.id, exp = exp}
                        role:setSkill(item.id, roleSkill)
                        role:addItemCount(item.id, -1)
                        ChangShengJueYinAndYangLearnState = false

                        self:__onUseAft()
                    end,
                    function()
                        ChangShengJueYinAndYangLearnState = false
                    end
                )
            end
        end
    else
        self:__richPrint("你拿起这张图谱细细研读，但上刻字符晦涩难懂，你想了许久也没有头绪。")
    end

    self:__onUseAft()
end

-- @desc 走穴十四经书页特殊处理
function RoleUseItem_SkillBook:__zouXueJing()
    local role = self._role
    local item = self._item

    if role:getInheritFlag("item_" .. item.id) == true then
        self:__popText("已经学习走穴十四经！")
    elseif item.id == "zouxueshisijing2" and role:getInheritFlag("item_zouxueshisijing1") ~= true then
        self:__popText("请先学习走穴十四经上篇！")
    else
        local skillLvTab = {
            zouxueshisijing1 = 50,
            zouxueshisijing2 = 100
        }
        local skill = Skill:getSkill(item.skillid)
        local result = false
        if skillLvTab[item.id] ~= nil and role:getLv() >= skillLvTab[item.id] then
            result = true
        else
            result = true
        end
        if result == false then
            self:__popText("也许是缺乏实战经验，你对[" .. tostring(skill.name) .. "]的心法总是无法领会。")
        else
            role:addSkillLv(item.skillid, 50)
            role:addItemCount(item.id, -1)
            role:setInheritFlag("item_" .. item.id, true)
        end
    end

    self:__onUseAft()
end

return NewClass("RoleUseItem_SkillBook", {AbstractUseItem}, RoleUseItem_SkillBook)
000