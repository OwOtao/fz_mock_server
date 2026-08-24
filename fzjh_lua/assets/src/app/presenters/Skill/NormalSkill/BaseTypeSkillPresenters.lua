local class = require("third.class.NewClass")

local BaseSkillInfoPopPresenter = require("app.presenters.Skill.BaseSkillInfoPopPresenter")

local SkillConst = require("app.models.skill.SkillConst")

local SkillClassifyManager = require("app.FightSystem.FightSkill.SkillClassifyManager")

local BaseTypeSkillPresenters = {}

function BaseTypeSkillPresenters:create()
    local p = BaseTypeSkillPresenters:new()
    p:init()
    return p
end

function BaseTypeSkillPresenters:init()
    self.__costJing = 30
end

function BaseTypeSkillPresenters:showLayer()
    self.__role = self:getParentModel():getRole()

    self.__skillId = self:getParentModel():getSkillId()

    self.__skill = Skill:getSkill(self.__skillId)

    local name = self.__skill:getName()

    local desc = self.__skill:getStageDsc(self.__role)

    local dsc = self.__skill:getDsc()

    local exp = Helper:mathFloor(self.__role:getSkillExp(self.__skillId))

    local expDsc = exp .. "/" .. self:__getSkillLv() .. "级"

    local btn1 = nil

    local func1 = EMPTY_FUNC

    if self:__getSkillLv() < self.__role:getSkillLvLimit(self.__skillId) then
        btn1 = "研究"

        func1 = function()
            Audio:playEffect("daAnNiu")

            if self:__canYanJiu() then
                if self:__isMaxOverRoleLv() then
                    local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
                    local dialog = DialogALayer:getInstance()
                    dialog:hide()
                    dialog:show("本次基本武学研究完成后，研究所得的武学等级大于人物当前等级，基本武学研究完成后会和人物当前等级持平，溢出的经验将会被抹除，是否确认研究？")
                    dialog:setBack(false)
                    dialog:setButton1(
                        "确认",
                        function()
                            self:__yanJiu()
                        end
                    )

                    dialog:setButton2("取消")
                else
                    self:__yanJiu()
                end
            end
        end
    end

    self.__ui:setName(name)
    self.__ui:setSkillStageDsc(desc)
    self.__ui:setSkillDetailDsc(dsc)
    self.__ui:setSkillExpDsc(expDsc)
    self.__ui:setButton1(btn1, func1)
    self.__ui:setTextDesc1(false)
    self.__ui:setButton2(nil, EMPTY_FUNC)
    self.__ui:setTextDesc2(false)
    self.__ui:setThirdTypeVisible(true)
    self.__ui:setSkillThirdTypes(self:getParentModel():getTextSkillThridTypes())
    self.__ui:setUseTipVisible(false)
    self.__ui:setImageBackFunc(
        function()
            if self.__backFunc then
                self.__backFunc()
            end
            self.__ui:hide(true)
        end
    )

    self.__ui:show(true)
end

function BaseTypeSkillPresenters:__canYanJiu()
    if self:__getSkillLv() < 500 then
        PopText("研究突破的基本功必须大于500级。")
        return false
    end

    if self.__role:getAttr("jing") < self.__costJing then
        PopText("你的精力不够了，无法集中注意力来做研究。")
        return false
    end

    local costPot = self:__getCostPot()

    local pot = self.__role:getAttr("pot")

    if pot < costPot then
        PopText("你的潜能不够，没有办法研究。")
        return false
    end

    local prepareType = self:getParentModel():getCurrTabSkillType()

    if prepareType == "bingqi" then
        prepareType = self:getParentModel():getCurrBingQiPrepareType()
    end

    local prepareSkillId = self.__role:getPrepareSkill(prepareType)

    if prepareSkillId == nil then
        PopText("你只能研究你准备了特殊功夫的基本功。")
        return false
    end

    local prepareSkill = self.__role:getSkill(prepareSkillId)

    if prepareSkill == nil then
        PopText("当前准备的武功不存在")
        return false
    end

    local prepareSkillLv = Skill:getLv(prepareSkill.exp)

    if prepareSkillLv + 1 <= self:__getSkillLv() then
        PopText("你的[" .. tostring(Skill:getSkill(prepareSkillId):getName()) .. "]火候未到，没有办法帮助你提高")
        return false
    end

    local addExp = self:__getAddMaxExp()

    if addExp == 0 then
        addExp = 1
    end

    local ret = self.__role:canLevelUp(self.__skillId, addExp)

    if ret == true then
    else
        PopText(ret)
        return false
    end

    return true
end

function BaseTypeSkillPresenters:__yanJiu()
    --[[
		一次消耗30精力
		一次消耗 30*（200+悟性）*系数   系数暂定为1
		只能超过当前准备的武功1级
		只能从500级开始研究
	]]
    local costPot = self:__getCostPot()

    local addExp = self:__getAddMaxExp()

    RichPrint("main", "你研究了一会[" .. tostring(self.__skill:getName()) .. "]，似乎想通了些什么。")

    RichPrint("main", "HIY你的[" .. tostring(self.__skill:getName()) .. "HIY]进步了！")

    -- 内部有是否能够升级的判断
    local result = self.__role:addSkillExp(self.__skillId, addExp)

    if result == true then
        self.__role:addAttr("jing", -self.__costJing)

        self.__role:addAttr("pot", -costPot)

        RichPrint("main", "消耗:  精力 " .. tostring(self.__costJing) .. "点")

        RichPrint("main", "消耗:  潜能 " .. tostring(costPot) .. "点")

        addExp = math.floor(addExp)

        if addExp >= 0 then
            RichPrint("main", "你的 【" .. tostring(self.__skill:getName()) .. "】 经验 +" .. tostring(addExp))
        else
            RichPrint("main", "你的 【" .. tostring(self.__skill:getName()) .. "】 经验 -" .. tostring(math.abs(addExp)))
        end
    end

    local exp = Helper:mathFloor(self.__role:getSkillExp(self.__skillId))

    local lv = Helper:mathFloor(self.__role:getSkillLvWithRoleLvLimit(self.__skillId))

    self.__ui:setSkillExpDsc(exp .. "/" .. lv .. "级")

    if lv >= self.__role:getSkillLvLimit(self.__skillId) then
        self.__ui:setButton1(nil, EMPTY_FUNC)
    end

    self.__parentPresenter:refreshCurSelectItem()
end

function BaseTypeSkillPresenters:__getCostPot()
    return self.__costJing * (200 + self.__role:getFinalAttr("currInt")) * 0.5
end

--@desc: 获取武学研究所得经验
--@author:LvBin
--@time:2024-08-06 18:10:46
--@role:
--@return
function BaseTypeSkillPresenters:__getAddExp(maxAddExp)
    local costPot = self:__getCostPot()

    local addExp = costPot * (self.__skill:getPotEfficiency(self.__role) / 100)

    addExp = math.min(addExp, maxAddExp or addExp)

    return addExp
end

function BaseTypeSkillPresenters:__getAddMaxExp()
    local roleMaxSkillExp = self:__getSkillExpFromRoleLvMax()

    local currSkillExp = self.__role:getSkillExp(self.__skillId)

    local maxAddExp = roleMaxSkillExp - currSkillExp

    if maxAddExp < 0 then
        assert(false, "值获取有错误，检查代码或存档 roleMaxSkillExp:" .. roleMaxSkillExp .. " , currSkillExp:" .. currSkillExp)
    end

    return self:__getAddExp(roleMaxSkillExp - currSkillExp)
end

function BaseTypeSkillPresenters:__isMaxOverRoleLv()
    local roleLv = self.__role:getLv()
    local addExp = self:__getAddExp()

    local maxAddExp = self:__getAddMaxExp()

    if maxAddExp < addExp then
        return true
    else
        return false
    end
end

function BaseTypeSkillPresenters:__getSkillExpFromRoleLvMax()
    return Skill:getSkill(self.__skillId):getExp(self.__role:getLv() + 1) - 1
end

function BaseTypeSkillPresenters:__getSkillLv()
    return self.__role:getSkillLvWithRoleLvLimit(self.__skillId)
end

return class("BaseTypeSkillPresenters", {BaseSkillInfoPopPresenter}, BaseTypeSkillPresenters)
0