local ForgetPagePresenter = class("ForgetPagePresenter", cc.Layer)

function ForgetPagePresenter:create()
    local p = ForgetPagePresenter:new()
    p:init()
    return p
end

function ForgetPagePresenter:init()
    self.__ui = require("app.views.ui.SkillUI.MapActivePracticeUI"):create()

    self.__ui:addTo(self)
end

function ForgetPagePresenter:showLayer()
    self.__zhaoIdList = self.__model:getZhaoIdList()

    self.__zhaoLearnNum = self.__model:getZhaoLearnNum()

    self.__praResMap = self.__model:getPraResMap()

    self.__zhaoLearnMaxNum = self.__praResMap.number

    self:__initSkillTitleList()

    self:setIndex(1)

    self:setSkillId(nil)

    self:showTextAttr1()

    self:showTextAttr2()

    self:showTextDesc()

    self:showTabListView()

    self:refreshSkillListView()

    self:hideZhaoDesc()

    self:hidePanelTip()

    self.__ui:hideTitle()

    self.__ui:show()
end

function ForgetPagePresenter:__refreshLayer()
    self:showTextAttr2()

    self:showTextDesc()

    self:__initSkillTitleList()

    self:refreshSkillListView()
end

function ForgetPagePresenter:refreshSkillListView()
    self.__ui:lightTab(self.__skillTitleList[self.__index].name)

    self:__sortSkillList()
    
    self:__setSkillListView()
end

function ForgetPagePresenter:setModel(model)
    self.__model = model
end

function ForgetPagePresenter:setPlayer(player)
    self.__role = player
end

function ForgetPagePresenter:setIndex(index)
    self.__index = index
end

function ForgetPagePresenter:setSkillId(skillId)
    self.__skillId = skillId
end

function ForgetPagePresenter:setCallBack(callback)
    self.__callback = callback
end

function ForgetPagePresenter:runCallBack()
    if self.__callback then
        self.__callback()
    end
end

function ForgetPagePresenter:showTextAttr1()
    self.__ui:setTextAttr1("")
end

function ForgetPagePresenter:showTextAttr2()
    local yuanbaoNum = User:getRoleAttr("yuanbao")
    self.__ui:setTextAttr2("元宝："..yuanbaoNum)
end

function ForgetPagePresenter:showTextDesc()
    self.__ui:setTextDesc("陪练已掌握："..self.__zhaoLearnNum.."/"..self.__zhaoLearnMaxNum)
end

function ForgetPagePresenter:showTabListView()
    local retArray = {}
    for i,skillTab in ipairs(self.__skillTitleList) do
        local tab = {
            title = "",
            func = EMPTY_FUNC
        }
        tab["title"] = skillTab.name
        tab["func"] = function()
            self:setIndex(i)

            self:setSkillId(nil)

            self:refreshSkillListView()
        end
        table.insert(retArray, tab)
    end
    
    self.__ui:setTabListView(retArray)
end

function ForgetPagePresenter:__sortSkillList()
    local skillList = self.__skillTitleList[self.__index].list

    if #skillList > 1 then
        table.sort(skillList, function(a, b)
            local a_islimit = self:__zhaoIsLimitExp(a.id)

            local b_islimit = self:__zhaoIsLimitExp(b.id)

            if a_islimit == false and b_islimit == true then
                return true
            elseif a_islimit == true and b_islimit == false then
                return false
            else
                if self.__role:getSkillExp(a.id) == self.__role:getSkillExp(b.id) then
                    return a.id < b.id
                else
                    return self.__role:getSkillExp(a.id) < self.__role:getSkillExp(b.id)
                end
            end
        end)
    end
end

--招式列表的所有主动技能熟练度是否都达到上限
function ForgetPagePresenter:__zhaoIsLimitExp(skillId)
    local zhaos = self.__model:getSkillZhaos(skillId)

    for i,zhao in ipairs(zhaos) do
        local zhaoExp = self.__role:getSkillZhaoExp(zhao:getId())

        local maxZhaoLv = self.__role:getZhaoLvLimit(zhao:getId())
        
        local maxExp = self.__role:getZhaoExpLimit(zhao:getId(),maxZhaoLv)

        if zhaoExp < maxExp then
            return false
        end
    end

    return true
end

function ForgetPagePresenter:__setSkillListView()
    local retArray = {}
    local skillList = self.__skillTitleList[self.__index].list

    if MapIsEmpty(skillList) == false then
        for index,v in ipairs(skillList) do
            local tab = {
                name = "",
                image = Resource:getImgPath("title_flod"),
                func = EMPTY_FUNC
            }

            tab["name"] = v.name
            
            if v.id == self.__skillId then
                tab["image"] = Resource:getImgPath("title_unflod")
            end

            tab["func"] = function()
                self:setSkillId(v.id)

                self:__setSkillListView()

                local zhaos = self.__model:getSkillZhaos(v.id)

                if not MapIsEmpty(zhaos) then
                    local insetPos = index
                    for i,zhao in ipairs(zhaos) do
                        insetPos = insetPos + 1

                        local zhaoExp = self.__role:getSkillZhaoExp(zhao:getId())

                        local maxZhaoLv = self.__role:getZhaoLvLimit(zhao:getId())
                        
                        local maxExp = self.__role:getZhaoExpLimit(zhao:getId(),maxZhaoLv) 

                        self.__ui:insertActive(insetPos-1, 
                            {   
                                name = zhao:getName(), 
                                exp = Helper:mathFloor(zhaoExp).."/"..maxExp,
                                func = function()
                                    self:showZhaoDesc(zhao)
                                end
                            }
                        )
                    end
                    self.__ui:jumpToItem(index)
                end
            end
            table.insert(retArray, tab)
        end
    end

    self.__ui:setSkillListView(retArray)
end

function ForgetPagePresenter:__initSkillTitleList()
    self.__skillTitleList = {
        {name = "拳脚", list = {}},
        {name = "兵器", list = {}},
        {name = "轻功", list = {}},
        {name = "内功", list = {}},
        {name = "招架", list = {}},
    }

    --@desc 过滤不同招式属于同一个武学
    local filterMap = {}

    for i,zhaoId in ipairs(self.__zhaoIdList) do
        local skillId = Skill:getSkillIdByZhaoId(zhaoId)
        local skill = Skill:getSkill(skillId)
        if filterMap[skillId] ~= true and skill.methods then
            filterMap[skillId] = true

            for i,vtype in ipairs(skill.methods) do
                if vtype == SKILL_METHOD_TYPE_QUANJIAO then
                    table.insert(self.__skillTitleList[1].list,{id = skill.id,name = skill.name})
                elseif vtype == SKILL_METHOD_TYPE_NEIGONG then
                    table.insert(self.__skillTitleList[4].list,{id = skill.id,name = skill.name})
                elseif vtype == SKILL_METHOD_TYPE_QINGGONG then
                    table.insert(self.__skillTitleList[3].list,{id = skill.id,name = skill.name})
                elseif vtype == SKILL_METHOD_TYPE_ZHAOJIA and #skill.methods == 1 then
                    table.insert(self.__skillTitleList[5].list,{id = skill.id,name = skill.name})
                elseif vtype == SKILL_METHOD_TYPE_JIAN or vtype == SKILL_METHOD_TYPE_DAO or vtype == SKILL_METHOD_TYPE_GUN or vtype == SKILL_METHOD_TYPE_ANQI or vtype == SKILL_METHOD_TYPE_BIANFA or vtype == SKILL_METHOD_TYPE_SHUANGCHI or vtype == SKILL_METHOD_TYPE_QIN then
                    local temp = false
                    for _,tempSkill in ipairs(self.__skillTitleList[2].list) do
                        if tempSkill.id == skill.id then
                            temp = true
                        end
                    end

                    if temp == false then
                        table.insert(self.__skillTitleList[2].list, {id = skill.id,name = skill.name})
                    end

                end
            end
        end
    end
end

function ForgetPagePresenter:hideZhaoDesc()
    self.__ui:hideZhaoDesc()
end

function ForgetPagePresenter:showZhaoDesc(zhao)
    local retData = {}
    
    local zhaoExp = self.__role:getSkillZhaoExp(zhao:getId())

    local zhaoLv = self.__role:getSkillZhaoLv(zhao:getId())

    local maxZhaoLv = self.__role:getZhaoLvLimit(zhao:getId())
        
    local maxExp = self.__role:getZhaoExpLimit(zhao:getId(),maxZhaoLv)

    retData.name = zhao:getName()

    retData.desc = self.__role:getZhaoUseDesc(zhao:getId())
    
    if zhaoExp <= 0 then
        retData.level = "未习得"

        retData.exp = ""

        retData.needExp = ""
    else
        retData.level = tostring(zhaoLv).."重"
        
        retData.exp = "当前熟练度为："..Helper:mathFloor(zhaoExp).."/"..maxExp
        
        if zhaoExp >= maxExp then
            retData.needExp = "当前熟练度已满"
        else
            retData.needExp = ""
        end
    end

    retData.leftButtonName = nil

    retData.rightButtonName = "忘却"

    retData.rightFunc = function()
        self:hideZhaoDesc()

        local costYuanBaoNum = self.__model:getHomeServantConf("deleteCostYuanbao")

        local text = "是否确认遗忘"..zhao:getName().."主动技能？(本次遗忘消耗"..costYuanBaoNum.."元宝，遗忘后需重新授予残页后才可进行该主动技能的对练)"
        self:__showConfirmLayer(
            text,
            function()
                local zhaoId = zhao:getId()

                self.__model:forgetZhaoPage(
                    zhaoId,
                    function(isOk, errmsg, data)
                        if isOk then
                            self.__zhaoIdList = self.__model:getZhaoIdList()

                            self.__zhaoLearnNum = self.__model:getZhaoLearnNum()
                            
                            self:__refreshLayer()

                            self:runCallBack()

                            PopText("遗忘成功")
                        else
                            PopText(errmsg)
                        end
                    end
                )
                
            end
        )
    end

    self.__ui:showZhaoDesc(retData)
end

function ForgetPagePresenter:hidePanelTip()
    self.__ui:hidePanelTip()
end

function ForgetPagePresenter:__showConfirmLayer(text,func)
    local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")

    local dialog = DialogALayer:getInstance()
    
    dialog:hide()
    dialog:show(text)
    dialog:setButton1(
        "确定",
        function()
            func()
        end
    )
    dialog:setButton2("取消",EMPTY_FUNC)
    dialog:setWeChatVisible(false)
end

Helper:classDefNodeGetInstance(ForgetPagePresenter)
return ForgetPagePresenter
000