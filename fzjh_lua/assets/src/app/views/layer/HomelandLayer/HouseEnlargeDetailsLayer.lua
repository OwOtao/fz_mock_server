--房型扩建详情界面
--房型扩建界面
local HouseEnlargeDetailsLayer = class("HouseEnlargeDetailsLayer", LayerEx)
-- local HomelandRoleUtil = require("app.models.HomelandModel.HomelandRoleUtil")
local FangQiModel = require("app.models.HomelandModel.FangQiModel")

--@RefType [app.models.HomelandModel.HomelandUtil#HomelandUtil]
local HomelandUtil = require("app.models.HomelandModel.HomelandUtil")

function HouseEnlargeDetailsLayer:create()
    local p = HouseEnlargeDetailsLayer:new()
    p:init()
    return p
end

function HouseEnlargeDetailsLayer:init()
    local UI = require("Layer/HomelandUI/HouseEnlargeDetailsUI.lua").create()["root"]
    UI:addTo(self)
    Helper:convertUIByParent(self)
    
    self:setExplainText("特殊说明：扩建后，房屋内置房间将会被替换成以上描述房间，不保留已改造房间。")
    self:setBackButton()
end

function HouseEnlargeDetailsLayer:setPlanText(text)
    if text == nil then
        return
    end
    self.Text_Plan:setString(text)
end

function HouseEnlargeDetailsLayer:setExplainText(text)
    if text == nil then
        return
    end
    self.Text_explain:setString(text)
end

function HouseEnlargeDetailsLayer:setSuccessCallback(callback)
    if type(callback) ~= "function" then
        return
    end

    self._successCallback = callback
end

function HouseEnlargeDetailsLayer:hideLayer()
    PopupLayerController:hideLayer(
        "HouseEnlargeDetailsLayer",
        function(layer)
            if layer._successCallback then
                layer._successCallback = nil
            end

            if layer._textView ~= nil then
                layer.Panel_dsc:removeChild(self._textView)
                layer._textView = nil
            end
            layer:hide()
        end
    )
end

function HouseEnlargeDetailsLayer:showLayer(currFangqiMobanAttr, newFangQiId)
    self:getYinPiao()
    self:initialization(currFangqiMobanAttr, newFangQiId)
    self:setDetailsButton(currFangqiMobanAttr, newFangQiId)
    self:show()
end

--初始化界面
function HouseEnlargeDetailsLayer:initialization(currFangqiMobanAttr, newFangQiId)
    local fangqiMobanAttr = FangQiModel:getFangQiTemplateById(newFangQiId)

    if PRINT_MODE == 1 then
        Helper:print_lua_table(fangqiMobanAttr)
    end

    self.Text_dsc:setString(fangqiMobanAttr.typedsc)
    self.Text_add:setString("扩建新增:" .. Helper:getDef(fangqiMobanAttr.roomlist, ""))
    self.Text_money:setString("需要花费" .. currFangqiMobanAttr.levelcost .. "银票")

    local hxId = fangqiMobanAttr.hxId
    local HomelandRoomUtil = require("app.models.HomelandModel.HomelandRoomUtil")
    local huxinAttr = HomelandRoomUtil:getHuxinAttr(hxId)
    local mapAppearance = huxinAttr.mapAppearance

    self._textView = cc.Label:createWithTTF(mapAppearance, Resource:getFontPath("default"), 36)

    self._textView:setAnchorPoint(cc.p(0.5, 0.5))
    self._textView:setPosition(self.Panel_dsc.Text_tu:getPosition())
    self.Panel_dsc:addChild(self._textView)

    -- self.Panel_dsc.Text_tu:setString(mapAppearance)
end

--设置扩建按钮
function HouseEnlargeDetailsLayer:setDetailsButton(currFangqiMobanAttr, newFangQiId)
    local role = User:getRole()
    local mid = role:getHouseId()
    local yinpiao_num = currFangqiMobanAttr.levelcost
    local newFangqiMobanAttr = FangQiModel:getFangQiTemplateById(newFangQiId)
    self.Button_extend:releaseFunc(function()
        local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
		local dialog = DialogALayer:getInstance()
		dialog:hide()
		dialog:show("是否花费" .. currFangqiMobanAttr.levelcost .. "银票将" .. currFangqiMobanAttr.name .. "扩建为" .. newFangqiMobanAttr.name.."？")
        dialog:setRichText("是否花费" .. currFangqiMobanAttr.levelcost .. "银票将" .. currFangqiMobanAttr.name .. "扩建为" .. newFangqiMobanAttr.name.."？")
		dialog:setBack(false)
        dialog:setWeChatVisible(false)
		dialog:setButton1("确定" , function()
            HttpManagerEx:upgrandeUserMap(
                mid,
                newFangQiId,
                yinpiao_num,
                function(status, errcode, errmsg, data)
                    if 200 == status then
                        if 0 == errcode then
                            PopText("你的房屋扩建成功，请重新进入。")
                            --[[刷新副本,需要把本地对应的数据房契模版数据覆盖]]
                            local updateData = {
                                fqId = newFangQiId,
                                name = "HIY" .. FangQiModel:getFangQiTemplateById(newFangQiId).name .. "NOR",
                                roomnum = FangQiModel:getFangQiTemplateById(newFangQiId).roomnum
                            }
                            FangQiModel:updateInfo(updateData)

                            HomelandUtil:clearRoomFlag()

                            MainControllLayer:getLayer("MapLayer"):userQuit()

                            if self._successCallback then
                                self._successCallback()
                            end

                            self:hideLayer()
                        else
                            PopText(errmsg)
                        end
                    else
                        PopText(errmsg)
                    end
                end,
                IS_SHOW_WAITING
            )
        end)
		dialog:setButton2("取消",function()
		end)
    end)
end

--获取当前银票数量
function HouseEnlargeDetailsLayer:getYinPiao()
    HttpManagerEx:viewCurrencyByType(
        "yinpiao",User:getRole():getCurrencyVersion(),
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    self._currYinPiao = data.number
                    self.Text_yinpiao:setString("『银票』" .. self._currYinPiao)
                else
                    PopText(errmsg)
                    self:hideLayer()
                end
            else
                PopText(errmsg)
                self:hideLayer()
            end
        end,
        IS_SHOW_WAITING
    )
end

--设置返回
function HouseEnlargeDetailsLayer:setBackButton()
    self.Button_back:releaseFunc(
        function()
            self:hideLayer()
        end
    )
end

Helper:classDefNodeGetInstance(HouseEnlargeDetailsLayer)
return HouseEnlargeDetailsLayer
0000