local Resource = require("app.Resource")
local DataBase = require("app.DataBase")
local MenuLayer = class("MenuLayer", cc.Layer)
local DialogDLayer = require("app.views.layer.DialogLayer.DialogDLayer")
local SpineAnimator = require("third.animator.SpineAnimator.SpineAnimator")

local Test_xiao = false
local waitingLayer = nil

function MenuLayer:create()
    local p = MenuLayer:new()
    p:init()
    return p
end

function MenuLayer:init()
    do
        if self.__animator then
            self.__animator:removeFromParent()
        end
        
        if self._UI == nil then
            -- UI
            self._UI = require("Layer/MenuUI/MenuUI.lua").create()["root"]
            self:addChild(self._UI, 1)
            Helper:convertUI(self)
        end
        
        self.__animator = SpineAnimator:create(assert(spine38.NewSkeletonAnimation:createWithBinaryFile("Anim/ep2/skeleton.skel", "Anim/ep2/skeleton.atlas", 1), "动画初始化出错"))
        self.__animator:getSkeletonAnimation():setPosition(display.center)
        self.AnimContainer:addChild(self.__animator:getSkeletonAnimation())
        
        self.__animator:play("biaoti", false)
        -- self.__animator:getSkeletonAnimation():setVisible(false)
        self:delayFunc(
            self.__animator:getSkeletonAnimation():getAnimDuration("biaoti"),
            function()
                self.__animator:play("daiji", true)
            end
        )
    end

    -- 适应调整分辨率大小 ps: oppo、小米渠道必须拉伸,不拉伸不给审核通过
    local channelId = Game:getChannelId()

    if (channelId == "oppo" or channelId == "xiaomi") and Game:isCheckNewPackage() == NEED_CHECK_AND_IS_OPEN then
        cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(1080, 1920, cc.ResolutionPolicy.EXACT_FIT)
    else
        cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(1080, 1920, cc.ResolutionPolicy.SHOW_ALL)
    end

    -- 重置
    self.Text_reset:setVisible(false)

    self:delayFunc(
        0,
        function()
            Audio:playEffect("DaijiBGM", true)
        end
    )

    --转移设备
    self.Button_Transfer:setVisible(false)

    -- 开始游戏
    self.Button_startGame:setVisible(true)
    self.Button_startGame:setTouchEnabled(false)
    self.Text_Start:releaseFunc(
        function()
            self:Text_Start_releaseFunc()
        end
    )

    --设置按钮
    self.Panel_setup:setVisible(true)
    self.Text_setup:setString("设置")
    self.Panel_setup:releaseFunc(
        function()
            Audio:playEffect("xiaoAnNiu")
            -- 点击开始按钮之后 不能点击设置
            if self.Button_startGame:isVisible() == false then
                return
            end
            -- local ControllLayer = require("app.views.layer.ControllLayer")
            MainControllLayer:pushLayer("SetupLayerInMenuLayer")
            local SetupLayer = MainControllLayer:getInstance():getLayer("SetupLayerInMenuLayer")
            SetupLayer:show()
            SetupLayer:setPropertyHide()
        end
    )

    -- add by XiaoZhiWei 2017/07/06 08:46:00 判断是否需要开启服务器切换
    if Game:isOpenSwitchServer() == true then
        do -- 切换分区 add by TangJian 2017/07/04 19:02:49
            SwitchServerController:addUIRefreshFunc(
                function()
                    self.Text_serverName:setString(Helper:getDef(SwitchServerController:getCurrentServerName(), "分区选择"))
                end
            )

            self.Image_switchServer:releaseFunc(
                function()
                    local switchServerLayer = SwitchServerLayer:getInstance()
                    switchServerLayer:showAndUpdate()
                    switchServerLayer:setEntryGameFunc(
                        function()
                            self:Text_Start_releaseFunc()
                        end
                    )
                end
            )
        end
    else
        self.Text_serverName:setVisible(false)
        self.Image_switchServer:setVisible(false)
    end

    self.Panel_setup_0:setVisible(false)

    -- 如果不是从我们的应用进入游戏, 则踢出游戏
    if device.platform == "android" then
        if string.find(cc.FileUtils:getInstance():getWritablePath(), "com.iplay.assistant") or string.find(cc.FileUtils:getInstance():getWritablePath(), "sandbox") then
            cc.Director:getInstance():endToLua()
            return
        end
    end

    -- add by XiaoZhiWei 2018/02/02 17:18:35 oppo 设备的返回按钮事件监听

    if Game:getChannelId() == "oppo" then
        self:setButtonListener()
    end

    if DataBase:getData("user_protocol") == true then
        self.CheckBox_Policy:setSelected(true)
        self.CheckBox_Policy:setBright(true)
    else
        self.CheckBox_Policy:setSelected(false)
        self.CheckBox_Policy:setBright(false)
    end

    self:initButtonPolicy()

    -- add by XiaoZhiWei 2018/03/15 19:12:36 应用宝按钮修改需求
    do
        self:initStartButtons()
    end

    -- 小七渠道 UI 版本号和资源版本号
    do
        self:showXiaoQiUI()
    end

    -- 适龄图片显示
    do
        self:initAgeIndicationImage()
    end

    self:__initMessageUploadBtnClick()

    -- 防止作弊调度
    self:schedule(
        function(ft)
            MainCheatingAgainstSystem:update(ft)
            self.__animator:update(ft)
        end,
        0
    )
end

function MenuLayer:onAwake()
    SwitchServerController:updateServerList(
        function()
            self.Text_serverName:setString(Helper:getDef(SwitchServerController:getCurrentServerName(), "分区选择"))
        end
    )
end

function MenuLayer:__initMessageUploadBtnClick()
    self.Text_Right_Click:setString("信息上传")
    self.Panel_Right_Click:releaseFunc(
        function()
            require("app.models.collection.EnvCollection"):create():uploadEnv(
                function(result, code, message)
                    if message == nil then
                        PopText("未知错误")
                        return
                    end
                    if result == true then
                        PopText(message)
                    else
                        PopText(message .. ":" .. tostring(code))
                    end
                end
            )
        end
    )
end

function MenuLayer:Text_Start_releaseFunc()
    if PRINT_MODE == 1 then
        print("按键松开方法..")
    end

    local startFunc = function()
        -- 清空切换服务器按钮响应 add by TangJian 2017/06/28 23:24:16
        self.Image_switchServer:releaseFunc(
            function()
            end
        )

        self:delayFunc(
            2,
            function()
                if self._startGameFunc then
                    Audio:stopMusic()
                    self._startGameFunc()
                    self.__isClickStart = false
                end
            end
        )
        self.Button_startGame:setVisible(false)

        self.Text_Start_QQ:setVisible(false)
        self.Text_Start_WeiXin:setVisible(false)
        self.Text_Start_YouKe:setVisible(false)

        self.Button_Transfer:setVisible(false)
        self.Text_Start:setVisible(false)

        self.Panel_Policy:setVisible(false)

        self.Panel_AppInfo:setVisible(false)

        self.Panel_setup:setVisible(false)
        self.Panel_setup_0:setVisible(false)
        self.Panel_Right_Click:setVisible(false)
        self.Image_switchServer:setVisible(false)
        self.Text_vivo_1:setVisible(false)
        self.Text_vivo_2:setVisible(false)
        self.Text_vivo_3:setVisible(false)
        self.Text_vivo_4:setVisible(false)
        self.Text_vivo_5:setVisible(false)
        self.Text_vivo_6:setVisible(false)
        self.Text_game_version:setVisible(false)
        self.Text_res_version:setVisible(false)

        self.Image_ageIndication:setVisible(false)

        Audio:stopAllEffects()
        Audio:playEffect("Bajian")

        -- 友盟统计 登入
        if User:getUserId() > 0 then
            Mob.profileSignIn(User:getUserId())
        end

        self.__animator:play("dianji", false)
    end

    if self.CheckBox_Policy:isSelected() == false then
        PopText("请先阅读并同意“隐私政策”和”用户协议“，然后再体验游戏。")
        self.__isClickStart = false
        return
    end

    local CheckLoginlist = {
        ["oppo"] = true,
        ["4399"] = true,
        ["changyou"] = true,
        ["xseven"] = true,
        ["huawei"] = true,
        ["yyh"] = true,
        ["m233"] = true,
        ["xiaomi"] = true,
        ["dangle"] = true,
        ["vivo"] = true
    }
    if CheckLoginlist[Game:getChannelId()] == true and not (Game:getChannelId() == "dangle" and Game:getVersion() == "1.15.0") then
        if SdkMethod.LOGIN_SetCallback == nil then
            startFunc()
            return
        end

        AGE = -1

        local WaitingLayer = require("app.views.layer.PopLayer.WaitingLayer")
        waitingLayer = WaitingLayer:createInRunningScene()

        SdkMethod:LOGIN_SetCallback(
            function(eventName)
                if eventName == "loginSuccessed" or eventName == "notShow" then
                    if PRINT_MODE == 1 then
                        PopText("登陆成功")
                    end
                    waitingLayer:hideAndRemoveSelf()
                    startFunc()
                elseif eventName == "Show" then
                    if PRINT_MODE == 1 then
                        PopText("引导实名认证")
                    end

                    local GongGaoLayer = require("app.views.layer.DialogLayer.GongGaoLayer")
                    local dialog = GongGaoLayer:getInstance()
                    dialog:show()
                    dialog:setText("应渠道方要求，请前往“华为账号-个人信息-实名认证”页面进行实名认证，认证后即可进行游戏体验(请在2020年1月1日前进行实名认证,未实名认证的用户将不能使用游戏服务)，如有带来不便，尽请谅解！")
                    dialog:setTitle("通知")
                    if tonumber(Helper:date("%Y%m%d", GetTime())) < 20200101 then
                        dialog:setButton1("关闭")
                    else
                        dialog:setButton1()
                    end
                    waitingLayer:hideAndRemoveSelf()
                elseif eventName == "loginFail" then
                    -- SdkMethod:checkLogin()
                    if PRINT_MODE == 1 then
                        PopText("登陆失败")
                    end
                    waitingLayer:hideAndRemoveSelf()
                elseif eventName == "loginCancel" then
                    if PRINT_MODE == 1 then
                        PopText("登陆取消")
                    end
                    -- SdkMethod:checkLogin()
                    waitingLayer:hideAndRemoveSelf()
                end

                if eventName == "VerifieFail" then
                    if PRINT_MODE == 1 then
                        PopText("未认证")
                    end
                    AGE = -1
                    -- SdkMethod:checkLogin()
                    waitingLayer:hideAndRemoveSelf()
                end

                if tonumber(eventName) ~= nil then
                    if PRINT_MODE == 1 then
                        PopText("年龄小于十八岁. " .. eventName)
                    end
                    AGE = tonumber(eventName)
                    waitingLayer:hideAndRemoveSelf()
                    startFunc()
                end

                if eventName == "adult" then
                    AGE = 18
                    waitingLayer:hideAndRemoveSelf()
                    startFunc()
                end

                if eventName == "Verified" then
                    waitingLayer:hideAndRemoveSelf()
                    startFunc()
                end
                if eventName == "logout" then
                    Game:restart()
                end
            end
        )
        SdkMethod:checkLogin()

        if Game:getChannelId() == "huawei" then
            if Game:getVersion() ~= "1.11.0" then
                SdkMethod:Huawei_SetCallback(
                    function(dayDuration)
                        if Game:isOpenShiMing() == true then
                            if tonumber(dayDuration) == -1 then
                                SCREEN_TIME_OPEN = false
                            else
                                SCREEN_TIME_OPEN = true --防沉迷开关

                                Game:MonitorScreenTime(tonumber(dayDuration))
                            end
                        end
                    end
                )
            end
        elseif Game:getChannelId() == "yyh" then
            SdkMethod:Huawei_SetCallback(
                function(isadult)
                    print("-----isadult------- = ", isadult)
                    if Game:isOpenShiMing() == true then
                        if isadult == "true" then
                            SCREEN_TIME_OPEN = false
                        else
                            SCREEN_TIME_OPEN = true --防沉迷开关

                            Game:MonitorScreenTime()
                        end
                    end
                end
            )
        end
    else
        startFunc()
    end
end

function MenuLayer:setStartGameFunc(func)
    if waitingLayer ~= nil then
        waitingLayer:maxZ()
    end
    self._startGameFunc = func
end

function MenuLayer:StartGame()
    self:delayFunc(
        2,
        function()
            if self._startGameFunc then
                self._startGameFunc()
            end
        end
    )

    self.Button_startGame:setVisible(false)
    self.Button_Transfer:setVisible(false)
    Audio:stopAllEffects()
    -- Audio:playEffect("DaijiBGM")
    -- NEEDTODO idcode /music test
    -- self.coverAnim:playAnim("kaishi")
end

function MenuLayer:checkLogin()
    if SdkMethod.LOGIN_SetCallback == nil then
        return
    end

    AGE = -1

    local WaitingLayer = require("app.views.layer.PopLayer.WaitingLayer")
    waitingLayer = WaitingLayer:createInRunningScene()

    SdkMethod:LOGIN_SetCallback(
        function(eventName)
            if eventName == "loginSuccessed" or eventName == "notShow" then
                if PRINT_MODE == 1 then
                    PopText("登陆成功")
                end
                waitingLayer:hideAndRemoveSelf()
            elseif eventName == "Show" then
                if PRINT_MODE == 1 then
                    PopText("引导实名认证")
                end

                local GongGaoLayer = require("app.views.layer.DialogLayer.GongGaoLayer")
                local dialog = GongGaoLayer:getInstance()
                dialog:show()
                dialog:setText("应渠道方要求，请前往“华为账号-个人信息-实名认证”页面进行实名认证，认证后即可进行游戏体验(请在2020年1月1日前进行实名认证,未实名认证的用户将不能使用游戏服务)，如有带来不便，尽请谅解！")
                dialog:setTitle("通知")
                if tonumber(Helper:date("%Y%m%d", GetTime())) < 20200101 then
                    dialog:setButton1("关闭")
                else
                    dialog:setButton1()
                end
                waitingLayer:hideAndRemoveSelf()
            elseif eventName == "loginFail" then
                if PRINT_MODE == 1 then
                    PopText("登陆失败")
                end
                SdkMethod:checkLogin()
            elseif eventName == "loginCancel" then
                if PRINT_MODE == 1 then
                    PopText("登陆取消")
                end
                SdkMethod:checkLogin()
            end

            if eventName == "VerifieFail" then
                if PRINT_MODE == 1 then
                    PopText("未认证")
                end
                AGE = -1
                SdkMethod:checkLogin()
            end

            if tonumber(eventName) ~= nil then
                if PRINT_MODE == 1 then
                    PopText("年龄小于十八岁. " .. eventName)
                end
                AGE = tonumber(eventName)
                waitingLayer:hideAndRemoveSelf()
            end

            if eventName == "adult" then
                AGE = 18
                waitingLayer:hideAndRemoveSelf()
            end

            if eventName == "Verified" then
                waitingLayer:hideAndRemoveSelf()
            end
            if eventName == "logout" then
                Game:restart()
            end
        end
    )

    SdkMethod:checkLogin()
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/03/15 19:00:45
-- @desc 应用宝按钮需求
function MenuLayer:initStartButtons()
    self.Text_Start_QQ:setVisible(false)
    self.Text_Start_WeiXin:setVisible(false)
    self.Text_Start_YouKe:setVisible(false)
    self.Button_startGame_QQ:setTouchEnabled(false)
    self.Button_startGame_WeiXin:setTouchEnabled(false)
    self.Button_startGame_YouKe:setTouchEnabled(false)

    self.Text_Start:setVisible(true)

    if Game:getChannelId() == "yyb" or Game:getChannelId() == "yyb2" or Test_xiao then
        local jsonLoginInfo = SdkMethod:loginInfo()
        local loginInfo, isLogin = nil, false

        -- add by XiaoZhiWei 2018/03/15 19:26:44 判断是否登录,登录信息处理
        do
            if jsonLoginInfo == nil then
            else
                loginInfo = json.decode(jsonLoginInfo)
            end

            if MapIsEmpty(loginInfo) == false and loginInfo.login == true then
                isLogin = true
            else
                isLogin = false
            end

            -- add by XiaoZhiWei 2018/03/15 19:22:41 如果玩家已经登录,则继续使用原有的进入入口
            if isLogin == true then
                return
            end
        end

        -- add by XiaoZhiWei 2018/03/15 19:33:05 按钮初始化方法
        do
            -- add by XiaoZhiWei 2018/03/15 19:21:48 回调方法
            SdkMethod:setLoginCallBack(
                function(eventName)
                    if eventName == "success" then
                        -- PopText("登录成功")
                        self:Text_Start_releaseFunc()
                    elseif eventName == "faild" then
                        -- PopText("登录失败")
                        self.__isClickStart = false
                    else
                        PopText("未知的返回类型,请确认")
                        self.__isClickStart = false
                    end
                end
            )

            self.Text_Start_QQ:setVisible(true)
            self.Text_Start_WeiXin:setVisible(true)
            if Game:getVersion() == "1.13.0" or Game:getVersion() == "1.13.1" or Game:getVersion() == "1.14.0" then
                self.Text_Start_YouKe:setVisible(true)
            else
                self.Text_Start_YouKe:setVisible(false)
            end
            self.Text_Start:setVisible(false)

            self.Text_Start_QQ:releaseFunc(
                function()
                    if self.__isClickStart ~= true then
                        SdkMethod:startLogin("qq")
                        self.__isClickStart = true
                    end
                    -- print("点击QQ登录按钮,   SdkMethod:startLogin(qq)")
                end
            )

            self.Text_Start_WeiXin:releaseFunc(
                function()
                    if self.__isClickStart ~= true then
                        SdkMethod:startLogin("weixin")
                        self.__isClickStart = true
                    end
                    -- print("点击QQ登录按钮,   SdkMethod:startLogin(weixin)")
                end
            )

            self.Text_Start_YouKe:releaseFunc(
                function()
                    if self.__isClickStart ~= true then
                        SdkMethod:startLogin("youke")
                        self.__isClickStart = true
                    end
                    -- print("点击QQ登录按钮,   SdkMethod:startLogin(youke)")
                end
            )
        end
    else
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/02/02 16:55:41
-- @desc 按键监听事件
function MenuLayer:setButtonListener()
    if self._layerInScene == nil then
        local runningScene = cc.Director:getInstance():getRunningScene()
        self._layerInScene = cc.Layer:create()
        runningScene:addChild(self._layerInScene)
    end

    -- 以下为按键监听
    local eventDispatcher = self._layerInScene:getEventDispatcher()

    if self._layerInScene.touchListener ~= nil then
        eventDispatcher:removeEventListener(self._layerInScene.touchListener)
        self._layerInScene.touchListener = nil
    end

    self._layerInScene.touchListener = cc.EventListenerKeyboard:create()

    local listener = self._layerInScene.touchListener

    listener:registerScriptHandler(
        function(keyCode)
            if PRINT_MODE == 1 then
                print("点击返回键...", keyCode)
            end
            if keyCode == cc.KeyCode.KEY_BACKSPACE then
                if PRINT_MODE == 1 then
                    print("点击返回键...")
                end
                platformProcessKeyEvent(6, 39)
            end
        end,
        cc.Handler.EVENT_KEYBOARD_PRESSED
    )
    eventDispatcher:addEventListenerWithSceneGraphPriority(self._layerInScene.touchListener, self._layerInScene)
end

-- 隐私政策相关按钮
function MenuLayer:initButtonPolicy()
    self.Panel_Policy:setVisible(true)
    self.Panel_AppInfo:setVisible(true)

    self.Panel_Policy:addTouchEventListener(
        function(ref, eventType)
            if eventType == ccui.TouchEventType.ended then
                if self.CheckBox_Policy:isSelected() == true then
                    self.CheckBox_Policy:setSelected(false)
                    self.CheckBox_Policy:setBright(false)
                    DataBase:setData("user_protocol", false, false)
                else
                    self.CheckBox_Policy:setSelected(true)
                    self.CheckBox_Policy:setBright(true)
                    DataBase:setData("user_protocol", true, false)
                end
            end
        end
    )

    -- 查看隐私政策
    self.Text_Policy:releaseFunc(
        function()
            local layer = require("app.views.layer.CommunityLayer.CommunityLayer"):getInstance()
            layer:setUrl("http://fzjh.xiaohoutiaotiao.com/privacyPolicy")
            layer:setTitle("隐私政策")
            layer:show()
        end
    )

    self.Text_UserAgreement:releaseFunc(
        function()
            local layer = require("app.views.layer.CommunityLayer.CommunityLayer"):getInstance()
            layer:setUrl("http://fzjh.xiaohoutiaotiao.com/userAgreement")
            layer:setTitle("用户协议")
            layer:show()
        end
    )

    self.Text_RecordNum:releaseFunc(
        function()
            local layer = require("app.views.layer.CommunityLayer.CommunityLayer"):getInstance()
            layer:setUrl("https://beian.miit.gov.cn/#/home", true)
            layer:setTitle("")
            layer:show()
        end
    )
end

function MenuLayer:showXiaoQiUI()
    local isXiaoQi = Game:getChannelId() == "xseven"

    if isXiaoQi then
        local ver = Game:getVersion()
        local hotver = Game:getHotVersion()
        self.Text_game_version:setString("V" .. ver .. "." .. hotver)
        self.Text_game_version:setVisible(true)
        self.Text_res_version:setString("beta1.2.1")
        self.Text_res_version:setVisible(true)
        self.Image_switchServer:setPositionY(205.70)
    else
        self.Text_game_version:setVisible(false)
        self.Text_res_version:setVisible(false)
        self.Image_switchServer:setPositionY(55.70)
    end
end

function MenuLayer:initAgeIndicationImage()
    self.Image_ageIndication:setVisible(true)
    self.Image_ageIndication:setTouchEnabled(true)
    self.Image_ageIndication:releaseFunc(
        function()
            PopupLayerController:showLayer(
                "GamePopLayer",
                function(layer)
                    layer:setText(
                        [[                      			  《放置江湖》

                                        16+

1. 《放置江湖》是一款放置玩法的文字江湖RPG游戏，适用于年满16周岁 及以上的用户，建议未成年人在家长监护下使用游戏产品。

2. 本游戏基于虚拟的武侠世界为故事背景，有着独立的世界观，不会与现实相混淆。拥有丰富的主线剧情、支线剧情，以情景对话与探索冒险展开玩法。鼓励玩家收集养成，多门派体验，需要一定的思维来搭配武学完成目标。游戏中没有基于文字和语音的陌生人社交系统。

3. 本游戏中有用户实名认证系统，认证为未成年人的用户将接受以下管理:

游戏中部分玩法和道具需要付费，未满8周岁的用户不能付费; 8周岁以上的未满16周岁的未成年人用户，单次充值金额不得超过50元人民币，每月充值金额累计不得超过200元人民币; 16周岁以上的未成年人用户，单次充值金额不得超过100元人民币，每月充值金额累计不得超过400元人民币。未成年人用户仅可在周五、周六、周日和法定节假日每日20时至21时进行游玩。

4. 本游戏以探索故事为主题，放置玩法，轻松上手，带给玩家更好的享受休闲时间，做到放松身心，劳逸结合。]]
                    )

                    layer:setTitle("适龄提示")

                    layer:showLayer()

                    layer:setBackButtonFunc(
                        function()
                            PopupLayerController:hideLayer(
                                "GamePopLayer",
                                function(layer)
                                    layer:hideLayer()
                                end
                            )
                        end
                    )
                end
            )
        end
    )
end

function MenuLayer:showBindingMailLayer()
    self.Panel_back:setTouchEnabled(true)
    self.Panel_back:setLocalZOrder(99999)
    Account:getBindInfo(
        function(eventName, errmsg, email, phone, isBind, isLogout, auth)
            if eventName == "内测邮箱认证" then
                local DebugConfig = require("app.views.layer.DebugLayer.DebugConfig")
                DebugConfig:setRoleType(auth)
            elseif eventName == "内测邮箱未认证" then
                PopupLayerController:showLayer(
                    "BindingTestMailLayer",
                    function(layer)
                    end
                )
            end
            self.Panel_back:setTouchEnabled(false)
        end
    )
end

return MenuLayer
00000000000000