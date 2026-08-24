local XinShenPresenter = class("XinShenPresenter", cc.Layer)

function XinShenPresenter:create()
    local p = XinShenPresenter.new()
    p:__init()
    return p
end

function XinShenPresenter:__init()
    self.__ui = require("app.views.ui.LianGongUI.XinShenUI"):create()

    self.__ui:addTo(self)
end

function XinShenPresenter:showLayer()
    self.__xinShenSystem = User:getRole():getXinShenSystem()

    self.__player = self.__xinShenSystem:getPlayer()

    self.__baseXinShenMax = self.__xinShenSystem:getBaseXinShenMax()

    self.__maxLevel = self.__xinShenSystem:getMaxLevel()

    self.__nextRecoverTime = math.max(0,math.floor(self.__xinShenSystem:getXinShenRecoverInterval() - (GetTime() - self.__recoverTime) % self.__xinShenSystem:getXinShenRecoverInterval()))

    self:setTitle()

    self:setCurrXinShenText()

    self:setCurrXinShenMaxText()

    self:setXinShenRecover()

    self:setXinShenMaxUi()

    self:setButton1()

    self:setButton2()

    self:setButton3()

    self.__ui:showUI()

    if self._handle then
        self:unschedule(self._handle)
        self._handle = nil
    end

    self:createHandle()
end

function XinShenPresenter:createHandle()
    if self._handle then
        return
    end
    
    self._handle =
        self:schedule(
        function(ft)
            if self.__xinshen >= self.__xinshenMax then
                self:unschedule(self._handle)
                self._handle = nil
                return
            end

            self.__nextRecoverTime = math.max(0,math.floor(self.__xinShenSystem:getXinShenRecoverInterval() - (GetTime() - self.__recoverTime) % self.__xinShenSystem:getXinShenRecoverInterval()))

            if self.__nextRecoverTime <= 0 then
                local newXinShen = math.min(self.__xinshen + self.__xinShenSystem:getXinShenRecoverValue(),self.__xinshenMax)

                self:setXinShen(newXinShen)

                self:setCurrXinShenText()
            end

            self:setXinShenRecover()
        end,
        1
    )
end

function XinShenPresenter:setRecoverTime(time)
    self.__recoverTime = time
end

function XinShenPresenter:setXinShen(xinshen)
    self.__xinshen = xinshen
end

function XinShenPresenter:setXinShenMax(xinshenMax)
    self.__xinshenMax = xinshenMax
end

function XinShenPresenter:setXinShenMaxLevel(level)
    self.__level = level
end

function XinShenPresenter:setTitle()
    self.__ui:setTitle("心神")
end

function XinShenPresenter:setCurrXinShenText()
    self.__ui:setCurrXinShenText(self.__xinshen)
end

function XinShenPresenter:setCurrXinShenMaxText()
    self.__ui:setCurrXinShenMaxText(self.__xinshenMax)
end

function XinShenPresenter:setXinShenRecover()
    local text = ""

    if self.__xinshen >= self.__xinshenMax then
        text = "当前心神已达到心神上限"
    else
        local hour,min,sec = Helper:sec2timeDsc(self.__nextRecoverTime)

        local recoverValue = self.__xinShenSystem:getXinShenRecoverValue()

        text = min.."分钟"..sec.."秒后恢复"..recoverValue.."点心神"
    end

    self.__ui:setXinShenRecover(text)
end

function XinShenPresenter:setXinShenMaxUi()
    if self.__level < self.__maxLevel then
        local currXinShenData = self.__xinShenSystem:getXinShenMaxUpgradeDataByLevel(self.__level)
        local nextXinShenData = self.__xinShenSystem:getXinShenMaxUpgradeDataByLevel(self.__level + 1)

        local xinfaText = ""
        local maxXfLv = 0
        local skills = self.__player:getSkills()
        for skillId,v in pairs(skills) do
            local skill = Skill:getSkill(skillId)
            if skill ~= nil then
                if skill.type == SKILL_TYPE_SPECIAL then
                    if self.__player:getSkillLv(skillId) > maxXfLv then
                        maxXfLv = self.__player:getSkillLv(skillId)
                    end

                    if xinfaText == "" then
                        xinfaText = skill:getNoColorName()
                    else
                        xinfaText = xinfaText.."、"..skill:getNoColorName()
                    end
                end
            end
        end
        if xinfaText == "" then
            xinfaText = "无"
        end

        local levelStepText = ""
        if maxXfLv >= nextXinShenData.level then
            levelStepText = "(已达成)"
        else
            levelStepText = "("..maxXfLv.."/"..nextXinShenData.level..")"
        end

        self.__ui:setXinShenUpgrade(self.__baseXinShenMax + currXinShenData.maxMind.."→"..self.__baseXinShenMax + nextXinShenData.maxMind)
        self.__ui:setXinShenCondition("任意心法达到"..nextXinShenData.level.."级"..levelStepText)
        self.__ui:setXinFaText(xinfaText)
        self.__ui:setXinShenCost(nextXinShenData.deplete.."精力")
        self.__ui:setXinShenIsMaxVisible(false)
        self.__ui:setSubTitle5Visible(true)
        self.__ui:setSubTitle6Visible(true)
        self.__ui:setSubTitle7Visible(true)
    else
        self.__ui:setXinShenUpgrade("")
        self.__ui:setXinShenCondition("")
        self.__ui:setXinFaText("")
        self.__ui:setXinShenCost("")
        self.__ui:setXinShenIsMaxVisible(true)
        self.__ui:setSubTitle5Visible(false)
        self.__ui:setSubTitle6Visible(false)
        self.__ui:setSubTitle7Visible(false)
    end
end

function XinShenPresenter:setButton1()
    local isEnabled = true
    if self.__level >= self.__maxLevel then
        isEnabled = false
    end

    self.__ui:setButton1(
        "提升上限",
        function()
            local skills = self.__player:getSkills()
            local maxXfLv = 0
            for skillId,v in pairs(skills) do
                local skill = Skill:getSkill(skillId)
                if skill ~= nil then
                    if skill.type == SKILL_TYPE_SPECIAL and self.__player:getSkillLv(skillId) > maxXfLv then
                        maxXfLv = self.__player:getSkillLv(skillId)
                    end
                end
            end

            local nextXinShenData = self.__xinShenSystem:getXinShenMaxUpgradeDataByLevel(self.__level + 1)
            
            if maxXfLv < nextXinShenData.level then
                PopText("未满足提升心神上限的条件")
                return
            end

            local jing = self.__player:getAttr("jing")

            if jing < nextXinShenData.deplete then
                PopText("心神上限升级消耗的资源不足")
                return
            end

            self.__xinShenSystem:upgradeXinShenLevel(function(ok, data)
                if ok then
                    PopText("提升成功")
                    
                    self.__level = self.__level + 1
                    
                    self.__player:addAttr("jing", -nextXinShenData.deplete)

                    if self.__xinshen >= self.__xinshenMax then
                        self:setRecoverTime(GetTime())
                        self:createHandle()
                    end

                    self:setXinShen(data.curr)
                    self:setXinShenMax(data.max)
                    self:setButton1()
                    self:setXinShenMaxUi()
                    self:setCurrXinShenMaxText()
				else
					local msg = data
					PopText(msg)
				end
			end)
        end,
        isEnabled
    )
end

function XinShenPresenter:setButton2()
    self.__ui:setButton2(
        "关闭",
        function()
            self:hideLayer()
        end
    )
end

function XinShenPresenter:setButton3()
    self.__ui:setButton3(
        "回复心神",
        function()
            self.__xinShenSystem:getItemMap(function(ok, data)
                if ok then
                    PopupLayerController:showLayer("XinShenRecoveryPresenter",function(layer)
                        layer:setXinShen(self.__xinshen)
                        layer:setXinShenMax(self.__xinshenMax)
                        layer:setRecoverTime(self.__recoverTime)
                        layer:setRecoverItemMap(data.itemMap)
                        layer:setCallBack(function(xinshenNum)
                            self:setXinShen(xinshenNum)
                            self:setCurrXinShenText()
                            self:setXinShenRecover()
                        end)
                        layer:showLayer()
                    end)    
                else
                    PopText(data)
                end
            end)
        end
    )
end

function XinShenPresenter:hideLayer()
    PopupLayerController:hideLayer(
        "XinShenPresenter",
        function(layer)
            if self._handle then
                self:unschedule(self._handle)
                self._handle = nil
            end
            self.__ui:hideUI()
        end
    )
end

Helper:classDefNodeGetInstance(XinShenPresenter)
return XinShenPresenter
0000000