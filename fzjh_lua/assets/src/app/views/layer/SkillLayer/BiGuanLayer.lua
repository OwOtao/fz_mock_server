local BiGuanLayer = class("BiGuanLayer", cc.Layer)

--@RefType [app.models.BiGuan.BiGuanModel#BiGuanModel]
local BiGuanModel = require("app.models.BiGuan.BiGuanModel")

function BiGuanLayer:create()
    local p = BiGuanLayer:new()
    p:init()
    return p
end

function BiGuanLayer:init()
    self._UI = require("Layer/Dialog/Dialog3UI.lua").create()["root"]
    self._UI:addTo(self)

    Helper:convertUIByParent(self)

    self.Image_kuang.Panel_state:setVisible(false)

    self.Image_kuang.Panel_row:setVisible(false)

    self.Panel_back:releaseFunc(
        function()
            self:hideLayer()
        end
    )
end

function BiGuanLayer:hideLayer()
    PopupLayerController:hideLayer(
        "BiGuanLayer",
        function(layer)
            layer:hide()
        end
    )
end

--@author:Liang SongQiang
--@time:2018-06-10 19:33:28
--@RefType [app.models.BiGuan.BiGuanModel#BiGuanModel]
function BiGuanLayer:showLayer(biGuanModel)
    if biGuanModel == nil then
        self:hideLayer()
        return
    end

    --@RefType [app.models.BiGuan.BiGuanModel#BiGuanModel]
    self._biGuanModel = biGuanModel

    self.__callbackFunc = nil

    self.Image_kuang.ListView_list:setContentSize(self.Image_kuang:getContentSize())
    self.Image_kuang.ListView_list:move(cc.p(540, 300))

    self:showInfoList()

    self:createBtn()

    self:show()
end

function BiGuanLayer:setCallback(func)
    self.__callbackFunc = func
end

function BiGuanLayer:showInfoList()
    local role = self._biGuanModel:getRole()

    self.Image_kuang.ListView_list:removeAllItems()

    local list = {}
    local config = {}

    if self._biGuanModel:getStatus() == self._biGuanModel.BIGUAN_STATUS.RUNNING then
        self:setTitle("正在闭关修炼 【" .. self._biGuanModel:getSkillName() .. "】 中")
        config = {
            "createSkillNamePanel",
            "createRemainTimePanel",
            "createCostPanel",
            "createSuccessRatePanel",
            "createFailRatePanel"
        }

        if self._biGuanModel:getJingXinWan() == 0 then
            table.insert(config, "createMonsterRatePanel")
        end

    elseif self._biGuanModel:getStatus() == self._biGuanModel.BIGUAN_STATUS.NOT_START then
        self:setTitle("你要开始闭关 【" .. self._biGuanModel:getSkillName() .. "】 吗？")

        config = {
            "createSkillNamePanel",
            "createUseTimePanel",
            "createCostPanel",
            "createSuccessRatePanel",
            "createFailRatePanel"
        }

        if self._biGuanModel:getJingXinWan() == 0 then
            table.insert(config, "createMonsterRatePanel")
        end

    elseif self._biGuanModel:getStatus() == self._biGuanModel.BIGUAN_STATUS.FNIISH then
        
    end
    for i, funName in ipairs(config) do
        local row = self[funName](self)
        self.Image_kuang.ListView_list:pushBackCustomItem(row)
    end
end

function BiGuanLayer:createResultPanel()
    local role = self._biGuanModel:getRole()

    local flag = role:getFlag("闭关结果")
    local result = ""
    if flag == "success" then
        result = "完美出关"
    elseif flag == "failed" then
        result = "普通出关"
    elseif flag == "monster" then
        result = "走火入魔"
    end

    return self:createRow("闭关结果",result)
end

function BiGuanLayer:createSkillNamePanel()
    return self:createRow("闭关心法：", self._biGuanModel:getSkillName())
end

function BiGuanLayer:createUseTimePanel()
    local title = "闭关时间："

    local time = self._biGuanModel:getUseTime()

    local text = "一分钟"
    if time > 0 then
        text = time .. "小时"
    end

    return self:createRow(title, text)
end

function BiGuanLayer:createRemainTimePanel()
    local text = ""

    local remainTime = self._biGuanModel:calReaminTime()

    local hour, min, sec = Helper:sec2timeDsc(remainTime)

    if hour >= 1 then
        text = text .. hour .. "小时"
    end
    if min >= 1 then
        text = text .. min .. "分钟"
    end
    if hour <= 0 and sec >= 0 then
        text = text .. sec .. "秒"
    end

    return self:createRow("闭关时间：",text)
end

function BiGuanLayer:createCostPanel()
    return self:createRow("消耗潜能：", math.floor(self._biGuanModel:getCost()))
end

function BiGuanLayer:createSuccessRatePanel()
    local title = "完美出关："

    local skillLv = self._biGuanModel:getskillLv()

    local successRate = self._biGuanModel:getSuccRate()

    local addLv = self._biGuanModel:getAddSkillLv()

    local text = successRate .. "%   （" .. skillLv .. "→" .. skillLv + addLv .. "）"

    return self:createRow(title, text)
end

function BiGuanLayer:createFailRatePanel()
    local title = "普通出关："

    local skillLv = self._biGuanModel:getskillLv()

    local failRate = self._biGuanModel:getFailRate()

    local addLv = self._biGuanModel:getFailAddSkillLv()

    local text = failRate .. "%   （" .. skillLv .. "→" .. skillLv + addLv .. "）"

    return self:createRow(title, text)
end

function BiGuanLayer:createMonsterRatePanel()
    local title = "RED走火入魔："

    local skillLv = self._biGuanModel:getskillLv()

    local monsterRate = self._biGuanModel:getMonsterRate()

    local addLv = self._biGuanModel:getMonsterAddSkillLv()

    local text = "RED" .. monsterRate .. "%   （" .. skillLv .. "→" .. skillLv + addLv .. "）NOR"

    return self:createRow(title, text)
end

function BiGuanLayer:createRow(name, num)
    local panel = self.Image_kuang.Panel_row:clone()
    Helper:convertUIByParent(panel)
    panel.Text_title:setString(name)
    panel.Text_num:setString(tostring(num))
    panel:setVisible(true)
    return panel
end

function BiGuanLayer:createBtn()
    --@RefType [app.models.role.Role#Role]
    local role = self._biGuanModel:getRole()

    if role:isInCurrState(ROLE_CURR_STATE_BIGUAN) then
        self.Button_1.Text_name:setString("出关")
        self.Button_1:releaseFunc(
            function()
                if self._biGuanModel:getJingXinWan() ~= 0 then
					local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
					local dialog = DialogALayer:getInstance()

					dialog:show("你已经使用了静心丸，取消后将丢失静心丸效果，是否确定？")
					dialog:setButton1("确定", function()
						self:stopBiGuan()
					end)
					dialog:setButton2("取消")
                    dialog:setWeChatVisible(false)
				else
					self:stopBiGuan()
				end
                self:hideLayer()
            end
        )

        self.Button_2.Text_name:setString("关闭")
        self.Button_2:releaseFunc(
            function()
                self:hideLayer()
            end
        )

        self.Button_1:setVisible(true)
        self.Button_2:setVisible(true)
        self.Button_3:setVisible(false)
        self.Button_4:setVisible(false)
    else
        self.Button_1.Text_name:setString("开始")
        self.Button_1:releaseFunc(
            function()
                self._biGuanModel:startBiGuan()
                self:hideLayer()
            end
        )

        self.Button_2.Text_name:setString("静心丸")
        self.Button_2:releaseFunc(
            function()
                local successRate = self._biGuanModel:getSuccRate()
                if successRate >= 100 then
                    PopText("已经可以完美出关,不需要再服用静心丸了")
                    return
                end

                self._biGuanModel:useJingXinWan(
                    function()
                        self:showInfoList()
                    end
                )

            end
        )

        self.Button_3.Text_name:setString("延长时间")
        self.Button_3:releaseFunc(
            function()
                local successRate = self._biGuanModel:getSuccRate()
                if successRate >= 100 or self._biGuanModel:getUseTime() == 72 then
                    PopText("闭关时间已经够了")
                    return
                end

                self._biGuanModel:addUseTime()

                self:showInfoList()
            end
        )

        self.Button_4.Text_name:setString("关闭")
        self.Button_4:releaseFunc(
            function()
                self:hideLayer()
            end
        )

        self.Button_1:setVisible(true)
        self.Button_2:setVisible(true)
        self.Button_3:setVisible(true)
        self.Button_4:setVisible(true)
    end
end

function BiGuanLayer:setTitle(title)
    self.Panel_title.Text_title:setString(title)
end

function BiGuanLayer:stopBiGuan()
    self._biGuanModel:stopBiGuan()

    if self.__callbackFunc then
        self.__callbackFunc()
    end
end

Helper:classDefNodeGetInstance(BiGuanLayer)
return BiGuanLayer
00000