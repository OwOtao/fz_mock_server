local ActiveZhaoPracticePresenter = class("ActiveZhaoPracticePresenter", cc.Layer)

local Role = require("app.models.role.Role")

local PraType = {
    Normal = 1, --普通对练
    Fast = 2    --加速对练
}

function ActiveZhaoPracticePresenter:create()
    local p = ActiveZhaoPracticePresenter:new()
    p:init()
    return p
end

function ActiveZhaoPracticePresenter:init()
    self.__ui = require("app.views.ui.SkillUI.MapActivePracticeUI"):create()

    self.__ui:addTo(self)
end

function ActiveZhaoPracticePresenter:showLayer()
    self.__zhaoIdList = self.__model:getZhaoIdList()

    self.__praResMap = self.__model:getPraResMap()

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

function ActiveZhaoPracticePresenter:__refreshLayer()
    self:showTextAttr1()

    self:showTextAttr2()

    self:showTextDesc()
end

function ActiveZhaoPracticePresenter:refreshSkillListView()
    self.__ui:lightTab(self.__skillTitleList[self.__index].name)

    self:__sortSkillList()
    
    self:__setSkillListView()
end

function ActiveZhaoPracticePresenter:initData(dataInfo)
   self.__praDayNum = dataInfo.practice_day_num

   self.__praMaxNum = dataInfo.practice_max_num
   
   self.__curAttrNum = dataInfo.curr_num
   
   self.__maxAttrNum = dataInfo.max_num
end

function ActiveZhaoPracticePresenter:setModel(model)
    self.__model = model
end

function ActiveZhaoPracticePresenter:setPlayer(player)
    self.__role = player
end

function ActiveZhaoPracticePresenter:setIndex(index)
    self.__index = index
end

function ActiveZhaoPracticePresenter:setSkillId(skillId)
    self.__skillId = skillId
end

function ActiveZhaoPracticePresenter:showTextAttr1()
    local jing = Helper:mathFloor(self.__role:getNumAttr("jing"))
    local jingMax = Helper:mathFloor(self.__role:getJingMax())

    self.__ui:setTextAttr1("精力："..jing.."/"..jingMax)
end

function ActiveZhaoPracticePresenter:showTextAttr2()
    self.__ui:setTextAttr2(Role:getCHAttrName("ningshendan").."："..self.__curAttrNum.."/"..self.__maxAttrNum)
end

function ActiveZhaoPracticePresenter:showTextDesc()
    self.__ui:setTextDesc("今日已对练次数："..self.__praDayNum.."/"..self.__praMaxNum)
end

function ActiveZhaoPracticePresenter:showTabListView()
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

function ActiveZhaoPracticePresenter:__sortSkillList()
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
function ActiveZhaoPracticePresenter:__zhaoIsLimitExp(skillId)
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

function ActiveZhaoPracticePresenter:__setSkillListView()
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

                        local currIndex = insetPos-1
       
                        self.__ui:insertActive(currIndex, 
                            {   
                                name = zhao:getName(), 
                                exp = Helper:mathFloor(zhaoExp).."/"..maxExp,
                                func = function()
                                    self:showZhaoDesc(currIndex,zhao)
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

function ActiveZhaoPracticePresenter:__initSkillTitleList()
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

function ActiveZhaoPracticePresenter:hideZhaoDesc()
    self.__ui:hideZhaoDesc()
end

function ActiveZhaoPracticePresenter:showZhaoDesc(index,zhao)
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

    retData.leftButtonName = "对练"

    retData.leftFunc = function()
        self:hideZhaoDesc()
        
        local addExp = self.__model:calAddExp(zhao,PraType.Normal)

        local costJing = self.__model:calCostJing(zhao)

        local text = "是否确认对练"..zhao:getName().."主动技能。(本次对练消耗"..costJing.."精力，可增加"..addExp.."招式熟练度)"
        
        self:__showConfirmLayer(
            text,
            function()
                local canPractice , msg = self:__isCanPractice(zhao)
                
                if canPractice == false then
                    PopText(msg)
                    return
                end

                local canUp

                canUp, addExp, msg = self.__role:checkSkillZhaoCanUp(zhao:getId(), addExp)

                if canUp == false then
                    PopText(msg)
                    return
                end
                
                self.__model:zhaoPractice(
                    zhao:getId(),
                    addExp,
                    costJing,
                    PraType.Normal,
                    0,
                    function(isOk, errmsg, data)
                        if isOk then
                            self.__praDayNum = data.practice_day_num
                            
                            self.__curAttrNum = data.curr_num

                            local currExp = self.__role:getSkillZhaoExp(zhao:getId())

                            self:__refreshLayer()

                            self:__playText(
                                zhao:getName(),
                                addExp,
                                function()
                                    self.__ui:refreshPanelActive(index, {exp = Helper:mathFloor(currExp) .. "/" .. maxExp})
                                end
                            )
                        else
                            PopText(errmsg)
                        end
                    end
                )
                
            end
        )
    end

    retData.rightButtonName = "潜心\n对练"

    retData.rightFunc = function()
        self:hideZhaoDesc()

        local addExp = self.__model:calAddExp(zhao,PraType.Fast)

        local costJing = self.__model:calCostJing(zhao)

        local price = self.__model:calCostNingShenDan(self.__skillId, zhao:getId())

        local text = "是否确认潜心对练"..zhao:getName().."主动技能。(本次潜心对练消耗"..costJing.."精力，"..price..Role:getCHAttrName("ningshendan").."，可增加"..addExp.."招式熟练度)"
        self:__showConfirmLayer(
            text,
            function()
                local canPractice , msg = self:__isCanPractice(zhao)
                
                if canPractice == false then
                    PopText(msg)
                    return
                end

                canPractice , msg = self:__isCanFastPractice(price)
                
                if canPractice == false then
                    PopText(msg)
                    return
                end

                local canUp

                canUp, addExp, msg = self.__role:checkSkillZhaoCanUp(zhao:getId(), addExp)

                if canUp == false then
                    PopText(msg)
                    return
                end
                
                self.__model:zhaoPractice(
                    zhao:getId(),
                    addExp,
                    costJing,
                    PraType.Fast,
                    price,
                    function(isOk, errmsg, data)
                        if isOk then
                            self.__praDayNum = data.practice_day_num
                            
                            self.__curAttrNum = data.curr_num

                            local currExp = self.__role:getSkillZhaoExp(zhao:getId())

                            self:__refreshLayer()

                            self:__playText(
                                zhao:getName(),
                                addExp,
                                function()
                                    self.__ui:refreshPanelActive(index,{exp = Helper:mathFloor(currExp).."/"..maxExp,})
                                end
                            )
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

function ActiveZhaoPracticePresenter:__isCanPractice(zhao)
    local zhaoExp = self.__role:getSkillZhaoExp(zhao:getId())

    if zhaoExp <= 0 then
        return false , "该特殊招式你还未习得！"
    end

    if self.__praDayNum >= self.__praMaxNum then
        return false , "今日就到此为止，让陪练歇息歇息吧！"
    end

    local praResMap = self.__praResMap

    local canPraLv = praResMap.type

    if canPraLv < zhao:getLevel() then
        return false , "忠诚度等级不足，无法陪练该招式"
    end

    local costJing = self.__model:calCostJing(zhao)
    
    if self.__role:getNumAttr("jing") < costJing then
        return false , "您精力不足，无法练习"
    end

    local maxZhaoLv = self.__role:getZhaoLvLimit(zhao:getId())
                            
    local maxExp = self.__role:getZhaoExpLimit(zhao:getId(),maxZhaoLv) 
    
    if zhaoExp >= maxExp then
        return false , "你的招式熟练度已达最高，无法练习"
    end

    return true
end

function ActiveZhaoPracticePresenter:__isCanFastPractice(price)
    local praResMap = self.__praResMap

    if praResMap.unlock == 0 then
        return false , "忠诚度等级不足，该陪练无法陪练加速"
    end

    if self.__curAttrNum < price then
        return false , Role:getCHAttrName("ningshendan").."数量不足，无法练习"
    end

    return true
end

function ActiveZhaoPracticePresenter:__showConfirmLayer(text,func)
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

function ActiveZhaoPracticePresenter:__playText(zhaoName,addExp,callback)
    local skillName = Skill:getSkill(self.__skillId).name

    local zhaoName = zhaoName

    local npcName = self.__model:getNpcName()

    local text = {
        "你招来"..npcName.." ，与其对练起了"..skillName.."中的"..zhaoName.."。",
        "你全神贯注于练习招式上，不知不觉进入了忘我的境界。",
        "时间慢慢过去，在不断地练习中，"..zhaoName.."被你运用得越来越纯熟。",
        "待你回过神来，已是小半个时辰过去了。",
        "你感觉你所用的"..zhaoName.."大有进益，心中对武学的感悟又多了不少。"
    }

    PopupLayerController:showLayer(
        "GlobalShadeLayer",
        function(layer)
            layer:setPopText("您正在练功，请专心")
            layer:showLayer()
        end
    )

    for i = 1, #text do
        self:delayFunc(
            0 + (i - 1) * 2,
            function()
                local str = text[i]

                RichPrint("main", str)

                if i == #text then
                    RichPrint("main", zhaoName .. " 熟练度 +" .. Helper:mathFloor(addExp))

                    if callback then
                        callback()
                    end

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
end

function ActiveZhaoPracticePresenter:hidePanelTip()
    self.__ui:hidePanelTip()
end

Helper:classDefNodeGetInstance(ActiveZhaoPracticePresenter)
return ActiveZhaoPracticePresenter
0000000000