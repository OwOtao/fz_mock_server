local DebugLayer = class("DebugLayer", cc.Layer)
local DebugConfig = require("app.views.layer.DebugLayer.DebugConfig")

function DebugLayer:create()
    local p = DebugLayer:new()
    p:init()
    return p
end

function DebugLayer:init()
    self._round = require("Layer/DebugUI/DebugUI.lua").create()["root"]
    self._round:addTo(self)

    Helper:convertUIByParent(self)
    -- 获得所有子节点

    -- local layer = ccui.Layout:create()
    -- self:addChild(layer)
    -- self.addTouchEventListener(layer)
end
function DebugLayer:onResume()
    self:showUI()
end
function DebugLayer:initTestLayer()
    self.Button_newFuncTest:setVisible(false)
    if Game:getVersion() == "1.1" then
        self.Button_testTG.Text_buttonName:setString("查看广告")
        self.Button_testTG:releaseFunc(
            function()
                if SdkMethod:GetNetWorkType() == "WWAN" then
                    PopText("未检测到网络,请检查设备的网络情况")
                    return
                end

                SdkMethod:UPLTV_setCallBack(
                    function(eventName)
                        PopText("回调事件类型 : " .. tostring(eventName))
                    end
                )
                if SdkMethod:UPLTV_isReady() == true then
                    SdkMethod:UPLTV_show("store_layer_ads")
                else
                    PopText("广告还没有准备好")
                end
            end
        )
    else
        self:setPanelBack()
        self:setGMButton()
        --
        self:setTGButton()
    end
end
function DebugLayer:initLayer()
    self:setPanelBack()
    self:setButtonGongGao()
    self:setButtonGongGaoHistory()
    self:setButtonDebugMode()
    self:setButtonPrintMode()
    self:setButtonKey()
    self:setButtonInherit()
    self:setTestLayer()
    self:setLogSystemTest()

    -----------------------------------------------------------------------------------------------------------
    -- @author TangJian
    -- @time 2016/11/01 11:37:42
    -- @desc 战斗测试入口
    self.Button_fight:releaseFunc(
        function()
            local Network = require("app.models.OnlineGame.Network")
            local network = Network:create("127.0.0.1", 5454)
            network:setIsHost(true)
            -- network:resetGame(
            -- 	function(success)
            network:connect(
                function(success)
                    if success then
                        print("OnlineFightInteractorImpl connect success")
                        network:subscribeRpc(
                            0,
                            function(funcName, params)
                                print("rpcCall:", funcName, params)
                            end
                        )

                        network:sendRpc(0, "funcName", {"args"})
                    end
                end
            )
            -- 	end
            -- )
        end
    )

    -----------------------------------------------------------------------------------------------------------
    -- @author TangJian
    -- @time 2016/11/08 16:14:04
    -- @desc 重启游戏
    self.Button_restartGame:releaseFunc(
        function()
            Game:restart()
        end
    )
end
-- 公告按钮
function DebugLayer:setButtonGongGao()
    self.Button_gonggao.Text_buttonName:setString("GM工具")
    self.Button_gonggao:releaseFunc(
        function()
            local TestFuncLayer = require("app.views.layer.DebugLayer.TestLayer")
            TestFuncLayer:getInstance():showLayer()
        end
    )
end

-- 历史公告按钮
function DebugLayer:setButtonGongGaoHistory()
    self.Button_gonggao_history.Text_buttonName:setString("程序用")
    self.Button_gonggao_history:releaseFunc(
        function()
            local GMLayer = require("app.views.layer.DebugLayer.GMLayer")
            GMLayer:getInstance():showLayer()
        end
    )
end

--测试快捷按钮
function DebugLayer:setButtonKey()
    self.Button_key.Text_buttonName:setString("按键列表")
end

-- 传承按钮
function DebugLayer:setButtonInherit()
    -- self.Button_inherit.Text_buttonName:setString("快捷功能")
    -- self.Button_inherit:releaseFunc(function()
    -- 	local TestFuncLayer = require("app.views.layer.DebugLayer.TestLayer")
    -- 	TestFuncLayer:getInstance():showLayer()
    -- end)
end

-- 调试模式开关
function DebugLayer:setButtonDebugMode()
    if DEBUG_MODE == 1 then
        self.Button_debug_mode.Text_buttonName:setString("关闭调试模式")
    else
        self.Button_debug_mode.Text_buttonName:setString("开启调试模式")
    end
    self.Button_debug_mode:releaseFunc(
        function()
            if DEBUG_MODE == 1 then
                self.Button_debug_mode.Text_buttonName:setString("开启调试模式")
                DEBUG_MODE = 2
            else
                self.Button_debug_mode.Text_buttonName:setString("关闭调试模式")
                DEBUG_MODE = 1
            end
        end
    )
end

-- 打印模式开关
function DebugLayer:setButtonPrintMode()
    if PRINT_MODE == 1 then
        self.Button_print_mode.Text_buttonName:setString("关闭打印模式")
    else
        self.Button_print_mode.Text_buttonName:setString("开启打印模式")
    end
    self.Button_print_mode:releaseFunc(
        function()
            if PRINT_MODE == 1 then
                self.Button_print_mode.Text_buttonName:setString("开启打印模式")
                PRINT_MODE = 2
            else
                self.Button_print_mode.Text_buttonName:setString("关闭打印模式")
                PRINT_MODE = 1
            end
        end
    )
end

function DebugLayer:setPanelBack() -- 设置背景点击事件
    self.Panel_back:releaseFunc(
        function()
            MainControllLayer:popLayer()
        end
    )
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/03/24 17:55:04
-- @desc 头像测试
function DebugLayer:headViewTest()
    local HeadView = require("app.views.ui.HeadView.HeadView")
    local headView = HeadView:create()
    self:addChild(headView)
    headView:setPosition(display.center)

    headView:showAnimHead("sword-attack11")
    -- headView:showImageHead("nan_head2")
end

function DebugLayer:setTestLayer()
    self.Button_newtest:setVisible(false)
end

--测试服按钮
function DebugLayer:setGMButton()
    self.Button_testGM:releaseFunc(
        function()
            local TestFuncLayer = require("app.views.layer.DebugLayer.TestGMLayer")
            TestFuncLayer:getInstance():showLayer()
        end
    )
end

function DebugLayer:setTGButton()
    self.Button_testTG:releaseFunc(
        function()
            local role = User:getRole()
            local MapList = Map:getMapListWithFilter()
            for i, v in pairs(MapList) do
                if i <= 40 then
                    role:setMapCompleted(v.id)
                end
            end
            PopText("已通关前40章节")
        end
    )
end

function DebugLayer:setLogSystemTest()
    self.Button_newFuncTest.Text_buttonName:setString("打印系统")
    self.Button_newFuncTest:releaseFunc(
        function()
            local LogTestLayer = require("app.views.layer.DebugLayer.LogTestLayer")
            LogTestLayer:getInstance():showLayer()
        end
    )
end

--项目组对应GM
-- function DebugLayer:showNormalUI()
--     local isTest = Game:getPlatformId() == "test"

--     if Game:getVersion() == "1.1" then
--         isTest = true
--     end
--     if isTest == true then
--         self:initTestLayer()
--     else
--         self:initLayer()
--     end

--     self.Button_testGM:setVisible(isTest)
--     self.Button_testTG:setVisible(isTest)
--     isTest = not isTest
--     self.Button_gonggao:setVisible(isTest)
--     self.Button_gonggao_history:setVisible(isTest)
--     self.Button_restartGame:setVisible(isTest)
--     self.Button_debug_mode:setVisible(isTest)
--     self.Button_print_mode:setVisible(isTest)

--     self.Button_inherit:setVisible(false)
--     self.Button_fight:setVisible(false)
--     self.Button_GM:setVisible(false)
--     self.Button_edit_attr:setVisible(false)
--     self.Button_key:setVisible(false)
--     self.Button_newtest:setVisible(false)
-- end

function DebugLayer:showUI()
    self:initLayer()
	self.Button_testGM:setVisible(false)
	self.Button_testTG:setVisible(false)
    self.Button_restartGame:setVisible(false)
    self.Button_inherit:setVisible(false)
	self.Button_key:setVisible(false)
	self.Button_edit_attr:setVisible(false)
    self.Button_fight:setVisible(false)
	self.Button_GM:setVisible(false)
	self.Button_newtest:setVisible(false)
    self.Button_gonggao_history:setVisible(true)
	self.Button_gonggao:setVisible(true)
	self.Button_restartGame:setVisible(true)
	self.Button_debug_mode:setVisible(true)
	self.Button_print_mode:setVisible(true)

	local btnConfig = GameChannelContext:getNotOpenDebugButtonConfig()
    if MapIsEmpty(btnConfig) == false then
        for __, btn in ipairs(btnConfig) do
            if self[btn] then
                self[btn]:setVisible(false)
            end
        end
    end
end

Helper:classDefNodeGetInstance(DebugLayer)
return DebugLayer
0