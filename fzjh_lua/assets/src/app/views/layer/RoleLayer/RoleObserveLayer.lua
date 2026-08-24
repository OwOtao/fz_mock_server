-- 观察人物界面,师门和副本都用该界面
--@SuperType [src.app.views.base.LayerEx#LayerEx]
local RoleObserveLayer = class("RoleObserveLayer", LayerEx)

--@RefType [app.views.layer.RoleLayer.RoleResConf#RoleResConf]
local RoleResConf = require("app.views.layer.RoleLayer.RoleResConf")

--@RefType [src.app.views.layer.RoleLayer.RoleFunctionButton#RoleFunctionButton]
local RoleFunctionButton = require("app.views.layer.RoleLayer.RoleFunctionButton")

--@RefType [src.app.models.role.RoleObserveModel#RoleObserveModel]
local RoleObserveModel = require("app.models.role.RoleObserveModel")

local SHOW_TYPE = {
    --@desc 副本NPC
    MAP_NPC = "MAP",
    --@desc 属性界面玩家信息
    PLAYER_ATTR = "PLAYER",
    --@desc 师门界面NPC
    TEACHER_TYPE = "TEACHER",

    RANKING = "RANKING",

    --@desc map family group 舍友
    MAP_FM = "MAP_FM",

    --@desc 棋盘
    MAP_CHESS = "MAP_CHESS"
}

-- local RoleObserveLayer = class("RoleObserveLayer", require("app.views.base.BaseLayer"))
function RoleObserveLayer:create()
    local p = RoleObserveLayer:new()
    p:init()
    return p
end

function RoleObserveLayer:init()
    self._UI = require("Layer/RoleUI/RoleObserveUI.lua").create()["root"]

    self._UI:addTo(self)

    Helper:convertUIByParent(self)

    self:setShowAndHideAnimType("ROLL")

    self.Panel_back:releaseFunc(
        function()
            self:hideLayer()
        end
    )

    self:setVisible(false)
end

function RoleObserveLayer:hideLayer()
    PopupLayerController:hideLayer(
        "RoleObserveLayer",
        function(layer)
            if layer._handle ~= nil then
                layer:unschedule(layer._handle)
                layer._handle = nil
            end

            if layer._chessHandle ~= nil then
                layer:unschedule(layer._chessHandle)
                layer._chessHandle = nil
            end
            layer:hide()
        end
    )
end

function RoleObserveLayer:showLayer(role, showType)
    --@desc 处理UI布局
    self:initUIWithShowType(role, showType)

    self:playRoleSound(role)

    self:show()
end

--[[
    @desc: 通过角色数据和功能列表直接创建角色观察界面
    author:TangJian
    time:2021-12-08 16:02:07
    --@role:
	--@functionList: 
    @return:
]]
function RoleObserveLayer:showLayerWithParams(role, functionList)
   self:initNormalUI()

    self:initBackground(role)

    self:setTitle(role)

    self:initDeskHelpBtn(role)

    self:initDeskStateText(role)

    self:initMapRoleUI()

    self:setDesc(RoleObserveModel:getRoleDesc(role))
    self:showBtns(functionList)

   self:playRoleSound(role)

   self:show()
end

--@desc 初始化背景边框
function RoleObserveLayer:initBackground(role)
    local path = RoleResConf:getFaceInfoFrame(role)
    self.Image_back:loadTexture(path)
    local texture = cc.TextureCache:getInstance():getTextureForKey(path)
    self.Image_back:setSize(texture:getContentSize())
end

function RoleObserveLayer:initUIWithShowType(role, showType)
    if showType == nil then
        assert(false, "args[2] is empty.")
    end

    self:initNormalUI()

    self:initBackground(role)

    self:setTitle(role)

    self:initDeskHelpBtn(role)

    self:initDeskStateText(role)

    switch(
        showType,
        {
            [SHOW_TYPE.MAP_NPC] = function(self, role)
                self:initMapRoleUI()
                self:initXiangXiBtns(role)
                if role.type2 == "familyGroup" then
                    self.Panel_HeadView:setVisible(true)
                end
                self:setDesc(RoleObserveModel:getRoleDesc(role))
                local funcList = RoleObserveModel:createMapRoleFuncList(role)
                self:showBtns(funcList)
                
            end,
            [SHOW_TYPE.MAP_FM] = function(self, role)
                self:initFGRoleUI()
                self:initHeadView(role)
                --@RefType [src.app.models.family.FamilyGroup#FamilyGroup]
                local FamilyGroup = require("app.models.family.FamilyGroup")
                local intimacyName, nextValue = FamilyGroup:getIntimacyDescAndNext(Helper:mathFloor(role.intimacy))
                self:setValues("〖" .. intimacyName .. "〗", "(" .. Helper:mathFloor(role.intimacy) .. "/" .. nextValue .. ")")
                self:setDesc(RoleObserveModel:getRoleDesc(role))
                local funcList = RoleObserveModel:createMapRoleFuncList(role)
                self:showBtns(funcList)
            end,
            [SHOW_TYPE.PLAYER_ATTR] = function(self, role)
                self:initAttrUI()
                self:initPanelLooksBtn(role)
                self:initPolymorphTime(role)
                self:setDesc(role:getDsc(User:getRole()))
                self.Text_id:setString("ID：" .. role:getAttr("userid"))
            end,
            [SHOW_TYPE.TEACHER_TYPE] = function(self, role)
                self:initMapRoleUI()
                self:setDesc(RoleObserveModel:getRoleDesc(role))
                local funcList = RoleObserveModel:getTeacherNpcFuncList(role)
                self:showBtns(funcList)
            end,
            [SHOW_TYPE.MAP_CHESS] = function(self, role)
                self:initMapRoleUI()
                self:initXiangXiBtns(role)
                self:initChessCd()
                self:setDesc(RoleObserveModel:getRoleDesc(role))
                local funcList = RoleObserveModel:createMapRoleFuncList(role)
                self:showBtns(funcList)
            end,
        },
        self,
        role
    )
end

function RoleObserveLayer:initPolymorphTime(role)
    local polymorph = role:getAttr("polymorph")

    local endTime = polymorph.endTime
    local cdTime = polymorph.cdTime

    if endTime - GetTime() > 0 then
        local useTime = GetTime()
        self.Panel_Looks.Text_time:setVisible(true)
        self._handle =
            self:schedule(
            function(ft)
                if GetTime() - useTime >= 1 then
                    local time = endTime - GetTime()
                    print("endTime=,", endTime, "time==", time)
                    local hour, min, sec = Helper:sec2timeDsc(time)
                    local text = hour .. "小时" .. min .. "分钟" .. sec .. "秒"
                    self.Panel_Looks.Text_time:setString("剩余时间:" .. tostring(text))
                    if time <= 0 then
                        self.Panel_Looks.Text_time:setVisible(false)
                    end
                    useTime = GetTime()
                end
            end,
            0.1
        )
    else
        self.Panel_Looks.Text_time:setVisible(false)
    end
end

function RoleObserveLayer:initPanelLooksBtn(role)
    self.Panel_Looks.Button_polymorph:releaseFunc(
        function()
            if role:getSkill("yirongshu") == nil then
                PopText("你尚未学得易容术")
                return
            end
            self:hideLayer()
            if role:checkRoleIsPolymorph() == false and role:checkPolymorphIsCd() == false then --未易容
                local YiRongShuLayer = require("app.views.layer.YiRongShuLayer.YiRongShuLayer")
                local dialog = YiRongShuLayer:getInstance()
                dialog:showLayer()
            elseif role:checkPolymorphIsCd() == true then --冷却中
                local polymorph = role:getAttr("polymorph")

                local endTime = polymorph.endTime
                local cdTime = polymorph.cdTime
            
                local a, b, c = Helper:sec2timeDsc(cdTime - GetTime())
                local cdTimetext = a .. "小时" .. b .. "分钟" .. c .. "秒"
                PopText("易容术还有" .. cdTimetext .. "可再次使用")
            else --易容中
                local YiRongShuNoLayer = require("app.views.layer.YiRongShuLayer.YiRongShuNoLayer")
                local dialog = YiRongShuNoLayer:getInstance()
                dialog:showLayer()
            end
        end
    )

    self.Panel_Looks.Button_DecorativeBox:releaseFunc(
        function()
            self:hideLayer()
            PopupLayerController:showLayer(
                "DecorativeBoxLayer",
                function(layer)
                    layer:showLayer()
                end
            )
        end
    )

end

function RoleObserveLayer:initXiangXiBtns(role)
    -- add by XiaoZhiWei 2017/05/09 16:37:57 佣兵模式详细按钮
    if role.baseId ~= nil and role.baseId == User:getRole():getCurrMap():getYongBingBaseId() then
        self.Button_DecorativeBox_xiangxi:setVisible(true)
        self.Button_DecorativeBox_xiangxi:releaseFunc(
            function()
                self:hideLayer(true)
                PopupLayerController:showLayer(
                    "YongBingInfoLayer",
                    function(layer)
                        layer:showRoleInfo(role)
                    end
                )
            end
        )
    end

    if User:getRole():getCurrMap():getMapType() == MAP_TYPE.MYHOME and role.jobType ~= nil then
        self.Button_DecorativeBox_xiangxi:setVisible(true)
        self.Button_DecorativeBox_xiangxi:releaseFunc(
            function()
                PopupLayerController:showLayer(
                    "HomelandRoleInfoLayer",
                    function(layer)
                        layer:setMiaoShuCallback(
                            function()
                                self:show()
                            end
                        )
                        layer:showLayer(role)
                    end
                )
                self:hideLayer(true)
            end
        )
    end
end

function RoleObserveLayer:initRichText()
    local richText = ExtRichTextScroll:create()

    richText:setAnchorPoint(0.5, 1.0)

    richText:setPosition(540.00, 1680)

    richText:setDirection(kCCScrollViewDirectionVertical)

    richText:getRichText():setVerticalSpace(5)

    richText:setTag(10000)

    self._UI:addChild(richText)

    return richText
end

function RoleObserveLayer:initNormalUI()
    self.Text_title:setPosition(526.00, 1737.96)

    self.Text_id:setPosition(44.00, 596.00)

    self.Text_id:setVisible(false)

    self.Text_chessCd:setVisible(false)

    self.Panel_Looks:setVisible(false)

    self.Button_DecorativeBox_xiangxi:setPosition(943, 630)
    self.Button_DecorativeBox_xiangxi:setVisible(false)

    self.Panel_HeadView:setVisible(false)

    self.ListView_FuncBtns:setVisible(false)

    self.Panel_Values:setVisible(false)

    self.richText = self._UI:getChildByTag(10000)

    if self.richText == nil then
        self.richText = self:initRichText()
    end

    self.Panel_back:setLocalZOrder(0)
    self.Image_back:setLocalZOrder(1)
    self.Text_id:setLocalZOrder(2)
    self.Text_title:setLocalZOrder(2)
    self.richText:setLocalZOrder(2)
    self.Panel_HeadView:setLocalZOrder(3)
    self.ListView_FuncBtns:setLocalZOrder(3)
    self.Button_DecorativeBox_xiangxi:setLocalZOrder(3)
    self.Panel_Looks:setLocalZOrder(3)
    self.Panel_Values:setLocalZOrder(3)
end

function RoleObserveLayer:initMapRoleUI()
    local DESC_SIZE = {width = 850, height = 560}
    self.richText:setSize(DESC_SIZE)
    self.richText:setPosition(540.00, 1680)

    self.ListView_FuncBtns:setPosition(540, 1107.15)

    self.ListView_FuncBtns:setVisible(true)
end

function RoleObserveLayer:initFGRoleUI()
    self.Panel_HeadView:setPosition(177, 1639)
    self.Text_title:setPosition(170, 1471.00)

    self.Panel_Values:setVisible(true)
    self.Panel_Values:setPosition(180,1363.10)

    local DESC_SIZE = {width = 684, height = 612}
    self.richText:setSize(DESC_SIZE)
    self.richText:setPosition(675.31,1744.20)
    
    self.ListView_FuncBtns:setPosition(540, 1107.15)
    self.ListView_FuncBtns:setVisible(true)


end

function RoleObserveLayer:initHeadView(role)
    local headUI = require("app.views.ui.HeadView.HeadView"):create()
	self.Panel_HeadView:addChild(headUI)
	headUI:setPosition(cc.p(self.Panel_HeadView.Node_HeadPos:getPosition()))
    headUI:setScaleX(0.8)
    headUI:setScaleY(0.8)
    
	--@RefType [src.app.presenters.HeadView.HeadViewPresenter#HeadViewPresenter]
	self.__headpresenter = require("app.presenters.HeadView.HeadViewPresenter"):create(role,headUI)
    self.__headpresenter:setClickEnable(false)

    self.Panel_HeadView:setVisible(true)
end

function RoleObserveLayer:initAttrUI()
    local DESC_SIZE = {width = 850, height = 780}

    self.richText:setSize(DESC_SIZE)

    self.richText:setPosition(540.00, 1680)

    self.Text_id:setVisible(true)

    self.Panel_Looks:setPosition(805, 775)

    self.Panel_Looks:setVisible(true)
end

function RoleObserveLayer:initChessCd()
    local startTime = Helper:getTimeStampWithStringDate("20220228", 0)
    local intervalTime = 168*60*60
    if GetTime() < startTime then
        self.Text_chessCd:setVisible(false)
        return
    end
    self.Text_chessCd:setVisible(true)
    self.Text_chessCd:setPosition(540,1150)
    self.Text_chessCd:maxZ()

    self._chessHandle =
        self:schedule(
        function(ft)
            local refreshTime = intervalTime - math.mod((GetTime() - startTime),intervalTime)
            local text = Helper:getTimeString(refreshTime)
            self.Text_chessCd:setString("刷新剩余时间：" .. tostring(text))
        end,
        0.1
    )
end

function RoleObserveLayer:setValues(name,value)
    self.Panel_Values.Text_Name:setString(name)
    self.Panel_Values.Text_Value:setString(value)
end

function RoleObserveLayer:setDesc(desc)
    self.richText:getRichText():removeAllElement()
    self.richText:pushBackText(desc, cc.c3b(208, 208, 208), 255, Resource:getFontPath("default"), 42)

    self:delayFunc(0.2, function()
        if self.richText then
            self.richText:jumpToTop()
        end
    end)
end

function RoleObserveLayer:setTitle(role)
    local title = ""
    if role.chenghao then
        title = role.chenghao
    end
    local nickname = ""
    if role.nickname then
        nickname = role.nickname
    end
    title = tostring(title) .. tostring(nickname) .. " " .. tostring(role.name)
    self.Text_title:setString(title)
end


function RoleObserveLayer:showBtns(funcList)
    local RoleFunctionButton = require("app.views.layer.RoleLayer.RoleFunctionButton")


    local functionList = {}
    for i, v in ipairs(funcList) do
        local btn =
            RoleFunctionButton:createFunction(
            v.btnName,
            function()
                Audio:playEffect("xiaoAnNiu")
                self:hideLayer()
                v.btnFunc()
            end
        )
        table.insert(functionList, btn)
    end

    self:createFuncBtnList(functionList)
end

function RoleObserveLayer:createFuncBtnList(functionList)
    self.ListView_FuncBtns:removeAllItems()
    if MapIsEmpty(functionList) == false then
        if #functionList > 5 then
            for i, btn in ipairs(functionList) do
                local panelIndex = Helper:mathFloor((i - 1) / 2)

                local panel = self.ListView_FuncBtns:getItem(panelIndex)

                if panel == nil then
                    panel = self.Panel_Btn:clone()
                    btn:setPosition(252, 50)
                    panel:addChild(btn)
                    self.ListView_FuncBtns:pushBackCustomItem(panel)
                else
                    btn:setPosition(694, 50)
                    panel:addChild(btn)
                end
            end
        else
            for i, btn in ipairs(functionList) do
                local panel = self.Panel_Btn:clone()
                btn:setPosition(473, 50)
                panel:addChild(btn)
                self.ListView_FuncBtns:pushBackCustomItem(panel)
            end
        end

        self.ListView_FuncBtns:jumpToTop()
        if #self.ListView_FuncBtns:getItems() > 5 then
            self.ListView_FuncBtns:setTouchEnabled(true)
        else
            self.ListView_FuncBtns:setTouchEnabled(false)
        end
    end
end

--@desc: 人物播放声音
--@author:Liang SongQiang
--@time:2019-04-22 14:39:03
function RoleObserveLayer:playRoleSound(role)
    if role.type == "item" then
        return
    end

    local effectName = RoleResConf:getRoleSound(role)

    Audio:playEffect(effectName)
end

function RoleObserveLayer:initDeskHelpBtn(role)
    if role.iType == "神功书案" then
        self.Button_help:setVisible(true)
        self.Button_help:setPosition(750,1060)
        self.Button_help:setLocalZOrder(4)
        self.Button_help:releaseFunc(function()
            HttpManagerEx:getHelpDocument(function(status, errcode, errmsg, data)
                if status == 200 and errcode == 0  and MapIsEmpty(data) == false and data.url ~= nil then
                    PopupLayerController:showLayer("GameHelpLayer", function(layer)
                        layer:setUrl(data.url)
                        layer:setTitle("放置江湖攻略客栈")
                        layer:show()	
                    end)
                else
                    PopText(errmsg)
                end
            end)
        end)
    else
        self.Button_help:setVisible(false)
    end
end

function RoleObserveLayer:initDeskStateText(role)
    if role.iType == "神功书案" then
        local player = User:getRole()
        local selfCreatedSkillSystem = player:getSelfCreatedSkillSystem()
        if selfCreatedSkillSystem:checkIsCreating() then
            local skill = selfCreatedSkillSystem:getSelfCreatingSkill()
            self.Text_createSkillState:setString("正在自创一门"..skill:getSkillTypeName().."武学")
            self.Text_createSkillState:setVisible(true)
            self.Text_createSkillState:setPosition(540,1250)
            self.Text_createSkillState:setLocalZOrder(5)
        else
            self.Text_createSkillState:setVisible(false)
        end
    else
        self.Text_createSkillState:setVisible(false)
    end
end


Helper:classDefNodeGetInstance(RoleObserveLayer)
return RoleObserveLayer
0000000000000