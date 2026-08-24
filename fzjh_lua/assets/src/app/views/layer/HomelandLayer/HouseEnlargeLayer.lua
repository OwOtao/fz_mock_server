--房型扩建界面
local HouseEnlargeLayer = class("HouseEnlargeLayer", LayerEx)
local HomelandRoleUtil = require("app.models.HomelandModel.HomelandRoleUtil")
local FangQiModel = require("app.models.HomelandModel.FangQiModel")

function HouseEnlargeLayer:create()
    local p = HouseEnlargeLayer:new()
    p:init()
    return p
end

function HouseEnlargeLayer:init()
    local UI = require("Layer/HomelandUI/HouseEnlargeUI.lua").create()["root"]
    UI:addTo(self)
    Helper:convertUIByParent(self)

    self:setBackButton()
end

function HouseEnlargeLayer:hideLayer()
    PopupLayerController:hideLayer(
        "HouseEnlargeLayer",
        function(layer)
            self._successCallback = nil
            layer:hide()
        end
    )
end

function HouseEnlargeLayer:setSuccessCallback(callback)
    self._successCallback = callback
end

function HouseEnlargeLayer:showLayer(affair)
    self._affair = affair
    self:initialization()
    self:show()
end

--设置返回
function HouseEnlargeLayer:setBackButton()
    self.Button_back:releaseFunc(
        function()
            self:hideLayer()
        end
    )
end

--初始化界面
function HouseEnlargeLayer:initialization()
    local role = User:getRole()
    local fq = role:getHomelandAttr("fq")

    --@desc 房契模板ID
    local fqId = fq.fqId

    local currFangqiMobanAttr = FangQiModel:getFangQiTemplateById(fqId)
    if PRINT_MODE == 1 then
        print("房屋升级ID：", currFangqiMobanAttr.levelid)
    end
    if currFangqiMobanAttr == nil or currFangqiMobanAttr.levelid == nil then
        assert(false,"HouseEnlargeLayer:initialization() 房契模版资源有问题 fqId = "..fqId)
    end
    local FangQiIdList = string.split(currFangqiMobanAttr.levelid, ";")
    local planOneFangQiId = FangQiIdList[1]
    local planTowFangQiId = FangQiIdList[2]
    if planOneFangQiId then
        local Plan1_dsc = FangQiModel:getFangQiTemplateById(planOneFangQiId).roomlist
        self.Text_Plan1:setVisible(true)
        self.Button_Detail1:setVisible(true)
        self.Text_Plan1_dsc:setVisible(true)

        self.Text_Plan1_dsc:setString("增加" .. Plan1_dsc)
        self.Button_Detail1:releaseFunc(
            function()
                PopupLayerController:showLayer(
                    "HouseEnlargeDetailsLayer",
                    function(layer)
                        layer:setPlanText("方案一")
                        layer:setSuccessCallback(
                            function()
                                self._affair.is_handle = 1
                                if self._successCallback then
                                    self._successCallback()
                                end
                                self:hideLayer()
                            end
                        )

                        layer:showLayer(currFangqiMobanAttr, planOneFangQiId, self._affair)
                    end
                )
            end
        )
    else
        self.Text_Plan1:setVisible(false)
        self.Button_Detail1:setVisible(false)
        self.Text_Plan1_dsc:setVisible(false)
    end

    if planTowFangQiId then
        local Plan2_dsc = FangQiModel:getFangQiTemplateById(planTowFangQiId).roomlist
        self.Text_Plan2:setVisible(true)
        self.Button_Detail2:setVisible(true)
        self.Text_Plan2_dsc:setVisible(true)
        self.Image_1:setVisible(true)

        self.Text_Plan2_dsc:setString("增加" .. Plan2_dsc)
        self.Button_Detail2:releaseFunc(
            function()
                PopupLayerController:showLayer(
                    "HouseEnlargeDetailsLayer",
                    function(layer)
                        layer:setPlanText("方案二")
                        layer:setSuccessCallback(
                            function()
                                self._affair.is_handle = 1
                                if self._successCallback then
                                    self._successCallback()
                                end
                                self:hideLayer()
                            end
                        )
                        layer:showLayer(currFangqiMobanAttr, planTowFangQiId, self._affair)
                    end
                )
            end
        )
    else
        self.Text_Plan2:setVisible(false)
        self.Button_Detail2:setVisible(false)
        self.Text_Plan2_dsc:setVisible(false)
        self.Image_1:setVisible(false)
    end
end

Helper:classDefNodeGetInstance(HouseEnlargeLayer)
return HouseEnlargeLayer
0000000